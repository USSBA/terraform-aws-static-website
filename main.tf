data "aws_canonical_user_id" "current_user" {}
locals {
  content_bucket_name = coalesce(var.content_bucket_name, "${var.domain_name}-static-content")
  content_bucket      = var.create_content_bucket ? aws_s3_bucket.content[0] : data.aws_s3_bucket.content[0]

  # CloudFront OAI Info
  create_oai                          = var.cloudfront_oai_id == ""
  cloudfront_oai_id                   = local.create_oai ? aws_cloudfront_origin_access_identity.oai[0].id : var.cloudfront_oai_id
  cloudfront_oai_iam_arn              = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${local.cloudfront_oai_id}"
  cloudfront_oai_access_identity_path = "origin-access-identity/cloudfront/${local.cloudfront_oai_id}"

  cloudfront_allowed_methods_map = {
    get : ["GET", "HEAD"]
    get_options : ["GET", "HEAD", "OPTIONS"]
    all : ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
  }
  cloudfront_allowed_methods = local.cloudfront_allowed_methods_map[var.cloudfront_allowed_methods]

}
resource "aws_route53_record" "record" {
  count   = var.hosted_zone_id != "" ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = module.cloudfront.distribution.domain_name
    zone_id                = module.cloudfront.distribution.hosted_zone_id
    evaluate_target_health = true
  }
}
resource "aws_s3_bucket" "logging" {
  bucket        = "${var.domain_name}-logs"
  force_destroy = var.force_destroy_buckets
  grant {
    id          = data.aws_canonical_user_id.current_user.id
    type        = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }
  grant {
    type        = "Group"
    permissions = ["READ", "WRITE"]
    uri         = "http://acs.amazonaws.com/groups/s3/LogDelivery"
  }
  grant {
    # AWS Logs Delivery account: https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html
    id          = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
    permissions = ["FULL_CONTROL"]
    type        = "CanonicalUser"
  }
  tags = merge(var.tags, var.tags_s3_bucket_logging, { Name = "CloudFront logs for ${var.domain_name}" })
}
resource "aws_s3_bucket" "content" {
  count         = var.create_content_bucket ? 1 : 0
  bucket        = local.content_bucket_name
  force_destroy = var.force_destroy_buckets
  tags          = merge(var.tags, var.tags_s3_bucket_content, { Name = "${var.domain_name} Static Content" })

  dynamic "cors_rule" {
    for_each = length(var.cors_allowed_origins) > 0 ? ["create"] : []
    content {
      allowed_headers = var.cors_allowed_headers
      allowed_methods = var.cors_allowed_methods
      allowed_origins = var.cors_allowed_origins
      expose_headers  = []
      max_age_seconds = 3000
    }
  }
}
data "aws_s3_bucket" "content" {
  count  = var.create_content_bucket ? 0 : 1
  bucket = local.content_bucket_name
}
# Static Bucket Policy
data "aws_iam_policy_document" "content" {
  # Grant read to cloudfront's OAI
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${local.content_bucket.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [local.cloudfront_oai_iam_arn]
    }
  }
}
resource "aws_s3_bucket_policy" "content" {
  count  = var.manage_content_bucket_policy ? 1 : 0
  bucket = local.content_bucket.id
  policy = data.aws_iam_policy_document.content.json
}
resource "aws_cloudfront_origin_access_identity" "oai" {
  count   = local.create_oai ? 1 : 0
  comment = "OAI for ${var.domain_name}"
}
module "cloudfront" {
  source  = "USSBA/cloudfront/aws"
  version = "~> 4.1"

  ipv6_enabled = true
  aliases      = [var.domain_name]

  default_root_object = var.default_subdirectory_object

  logging_enabled = true
  logging_config = {
    bucket          = aws_s3_bucket.logging.id
    prefix          = "cloudfront/"
    include_cookies = true
  }

  # TLS Configuration
  viewer_certificate = {
    acm_certificate_arn      = var.acm_certificate_arn
    minimum_protocol_version = "TLSv1.2_2018"
    ssl_support_method       = "sni-only"
    iam_certificate_id       = ""
  }

  s3_origins = [
    {
      origin_id              = local.content_bucket_name
      domain_name            = local.content_bucket.bucket_regional_domain_name
      origin_access_identity = local.cloudfront_oai_access_identity_path
    },
  ]

  # Default behavior
  default_cache_behavior = {
    allowed_methods                = local.cloudfront_allowed_methods
    cached_methods                 = ["GET", "HEAD"]
    origin_id                      = local.content_bucket_name
    default_ttl                    = var.default_ttl
    min_ttl                        = var.min_ttl
    max_ttl                        = var.max_ttl
    viewer_protocol_policy         = "redirect-to-https" # allow-all, https-only, redirect-to-https
    forward_cookies                = "all"
    forward_cookies_whitelist      = []
    forward_headers                = length(var.cors_allowed_origins) > 0 ? ["Origin", "Access-Control-Request-Method", "Access-Control-Request-Headers"] : []
    forward_querystring            = true
    forward_querystring_cache_keys = []
    function_association = flatten([
      var.hsts_header != "" ? [{
        event_type = "viewer-response"
        lambda_arn = "aws_cloudfront_function.security_headers_response[0].arn"
      }] : [],
      var.index_redirect || var.index_redirect_no_extension ? [{
        event_type = "viewer-request"
        lambda_arn = "aws_cloudfront_function.subdirectory_index[0].arn"
      }] : [],
    ])
  }
  tags = merge(var.tags, var.tags_cloudfront, { Name = "Cloudfront for ${var.domain_name}" })
}
resource "aws_cloudfront_function" "subdirectory_index" {
  count   = var.index_redirect || var.index_redirect_no_extension ? 1 : 0
  name    = "${terraform.workspace}-subdirectory-index"
  runtime = "cloudfront-js-1.0"
  comment = "${terraform.workspace} Subdirectory Index"
  publish = true
  code    = replace(replace(replace(file("${path.module}/subdirectory.js"), "TRAILING_SLASH_TO_INDEX", var.index_redirect), "NO_FILE_EXTENSION_TO_INDEX", var.index_redirect_no_extension), "DEFAULT_INDEX", var.default_subdirectory_object)
}
resource "aws_cloudfront_function" "security_headers_response" {
  count   = var.hsts_header != "" ? 1 : 0
  name    = "${terraform.workspace}-security-headers"
  runtime = "cloudfront-js-1.0"
  comment = "${terraform.workspace} Security Headers Injection on viewer-response"
  publish = true
  code    = replace(file("${path.module}/hsts.js"), "HEADER_VALUE", var.hsts_header)
}
