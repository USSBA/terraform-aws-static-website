module "simple_static_site" {
  # source = "USSBA/static-website/aws"
  # version = "~> 3.0"
  source = "../../"

  domain_name         = "site.example.com"
  acm_certificate_arn = "arn:aws:acm:us-east-1:123412341234:certificate/1234abcd-1234-abcd-1234-abcd1234abcd"

  # Optional
  hosted_zone_id              = "Z0123456789ABCDEFGHIJ"
  default_subdirectory_object = "index.html"
  hsts_header                 = "max-age=31536000"

  tags = {
    ManagedBy = "Terraform"
    foo       = "foo"
  }

  tags_cloudfront = {
    CloudFront = "Very Yes"
    bar        = "bar"
  }

  cloudfront_allowed_methods = "get"
}
