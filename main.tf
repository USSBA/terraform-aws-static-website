data "aws_canonical_user_id" "current_user" {}
locals {
  lambda_at_edge_associations = concat(
    local.subdirectory_index_association,
    local.hsts_header_association,
  )
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
  bucket = "${var.domain_name}-logs"
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
  tags = {
    Name = "CloudFront logs for ${var.domain_name}"
  }
}
resource "aws_s3_bucket" "static" {
  bucket = "${var.domain_name}-static-content"
  tags = {
    Name = "${var.domain_name} Static Content"
  }
}
# Static Bucket Policy
data "aws_iam_policy_document" "static" {
  # Grant read to cloudfront's OAI
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}
resource "aws_s3_bucket_policy" "static" {
  bucket = aws_s3_bucket.static.id
  policy = data.aws_iam_policy_document.static.json
}
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.domain_name}"
}
module "cloudfront" {
  source = "USSBA/cloudfront/aws"
  version = "~> 1.1"

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
      origin_id              = "static_bucket"
      domain_name            = aws_s3_bucket.static.bucket_regional_domain_name
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    },
  ]

  # Default behavior
  default_cache_behavior = {
    allowed_methods                = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods                 = ["GET", "HEAD"]
    origin_id                      = "static_bucket"
    default_ttl                    = 0
    min_ttl                        = 0
    max_ttl                        = 0
    viewer_protocol_policy         = "redirect-to-https" # allow-all, https-only, redirect-to-https
    forward_cookies                = "all"
    forward_cookies_whitelist      = []
    forward_headers                = []
    forward_querystring            = true
    forward_querystring_cache_keys = []
    lambda_function_association    = local.lambda_at_edge_associations
  }
}
