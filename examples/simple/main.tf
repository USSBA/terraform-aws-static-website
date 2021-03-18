module "simple_static_site" {
  # source = "USSBA/static-website/aws"
  # version = "~> 4.0"
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
  cors_allowed_origins       = ["https//www.sba.gov"]
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
        <p>Hello, Terraform!!</p>
      </body>
    </html>
  EOF
}
