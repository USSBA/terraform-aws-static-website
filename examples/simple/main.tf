locals {
  base_domain_name = "management.ussba.io"
}

## Fetch a pre-existing Route53 Zone and ACM Certificate
data "aws_route53_zone" "pre_existing" {
  name = "${local.base_domain_name}."
}
data "aws_acm_certificate" "pre_existing" {
  domain   = local.base_domain_name
  statuses = ["ISSUED"]
}

## Static Site
module "simple_static_site" {
  # source = "USSBA/static-website/aws"
  # version = "~> 4.0"
  source = "../../"

  domain_name         = "simple-static-site.${local.base_domain_name}"
  acm_certificate_arn = data.aws_acm_certificate.pre_existing.arn

  # Optional
  ## Ensures route53 record is created
  hosted_zone_id = data.aws_route53_zone.pre_existing.id
  ## Routes requests to `/foo/bar/` to `/foo/bar/index.html`
  index_redirect = true
  ## Routes requests to `/foo/bar` to `/foo/bar/index.html`
  index_redirect_no_extension = true
  ## Injects an HSTS header in all responses
  hsts_header = "max-age=31536000"

  ## Add tags to any resources that can accept them
  tags = {
    ManagedBy = "Terraform"
    foo       = "foo"
  }

  ## Add tags to just the cloudfront distribution
  tags_cloudfront = {
    CloudFront = "Very Yes"
    bar        = "bar"
  }

  cloudfront_allowed_methods = "get"
  cors_allowed_origins       = ["https//api.management.ussba.io"]
}

resource "aws_s3_bucket_object" "content_index" {
  bucket       = module.simple_static_site.content_bucket_id
  key          = "index.html"
  content_type = "text/html"
  content      = <<-EOF
    <html>
      <head>
        <title>Hello, Terraform!!</title>
      </head>
      <body>
        <p>Hello, Terraform!!  This file is actually /index.html</p>
      </body>
    </html>
  EOF
}

resource "aws_s3_bucket_object" "foo_index" {
  bucket       = module.simple_static_site.content_bucket_id
  key          = "/foo/index.html"
  content_type = "text/html"
  content      = <<-EOF
    <html>
      <head>
        <title>Hello, Terraform!!</title>
      </head>
      <body>
        <p>Hello, Terraform!!  This file is actually /foo/index.html</p>
      </body>
    </html>
  EOF
}

output "dns" {
  value = <<EOF
  Connect to CloudFront now!  Try these URLs:
  https://simple-static-site.${local.base_domain_name}
  https://simple-static-site.${local.base_domain_name}/
  https://simple-static-site.${local.base_domain_name}/foo
  https://simple-static-site.${local.base_domain_name}/foo/
  https://simple-static-site.${local.base_domain_name}/foo/index.html
  EOF
}
