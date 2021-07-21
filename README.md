# Terraform Simple Website

Sometimes you just want to get your simple static website up and running quickly.  And then you start to wonder about HTTPS, caching, logging, HSTS headers, Bucket Permissions, and so on.  Ain't nobody got time for that.  This handles that boilerplate for you and condenses the code into this:

```terraform
module "static_site" {
  source = "USSBA/static-website/aws"
  version = "~> 2.0"

  domain_name = "static.example.com"
  acm_certificate_arn = "arn:aws:acm:us-east-1:123412341234:certificate/1234abcd-1234-abcd-1234-abcd1234abcd"

  # Optional
  hosted_zone_id = "Z0123456789ABCDEFGHIJ"
  default_subdirectory_object = "index.html"
  hsts_header = "max-age=31536000"
}

```

## Features

* Redirect HTTP to HTTPS
* HTTPS
* Route53 Alias Records
* HSTS Headers
* Default index file resolution for root and subdirectories (`/files/` => `/files/index.html`)
* A simple bucket created with the name of `<domain-name>-static-content` for all your static hosting needs
* Optionally provide an existing static-content bucket

## Parameters

### Required

* `domain_name` - The domain name of your site
* `acm_certificate_arn` - The ACM cert matching your domain name to feed into cloudfront

### Optional

* `hosted_zone_id` - The hosted zone matching your domain; if provided, the module will create the Route53 recordset for you.  If not, you'll need to map the cloudfront DNS yourself
* `hsts_header` - The value of the HSTS header, eg `max-age=31536000`, helpful to let your users know you always want them using HTTPS.  With CloudFront, you need lambda@edge to do this, so... it will create it.
* `default_subdirectory_object` - If you want URLs ending in `/` to load a file, set this to something like `index.html`. With CloudFront, you need lambda@edge to do this, so... it will create it.
* `content_bucket_name` - Set the name of the content bucket.  Defaults to `<domain_name>-static-content`.
* `create_content_bucket` - Set whether module creates the bucket, or looks it up with a data-source.  Defaults to `true`.
* `manage_content_bucket_policy` - If you want to manage the bucket policy external to this module, set this to `false`.  In that case, you will be responsible for configuring the bucket to allow the OAI to read from the bucket.  Defaults to `true`
* `cloudfront_oai_id` - Provide a pre-existing OAI ID to grant access from CloudFront to S3.  If not provided, an OAI will be created for you by default.
* `cloudfront_allowed_methods` - Configure the allowed_methods of cloudfront.  Allowed values are `get`, `get_options`, `all`.  Default is `all`.  For more information, see [AWS documentation on Cache Behavior Allowed Methods](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cloudfront-distribution-defaultcachebehavior.html#cfn-cloudfront-distribution-defaultcachebehavior-allowedmethods)
* `force_destroy_buckets` - If set to true, buckets will be deleted on module destroy, regardless of data in those buckets.  Defaults to false.
* `tags` - Map of key-value tags to apply to all applicable resources. Defaults to no tags.
* `tags_s3_bucket_logging` - Map of additional key-value tags to apply to the s3 bucket containing logs. Any Name tag will be overridden by a dynamically generated tag. Default is no tags.
* `tags_s3_bucket_content` - Map of additional key-value tags to apply to the s3 bucket containing the static website content. Any Name tag will be overridden by a dynamically generated tag. Default is no tags.
* `tags_cloudfront` - Map of key-value tags to apply to the cloudfront distribution. Any Name tag will be overridden by a dynamically generated tag. Defaults to no tags.
* `cors_allowed_origins` - List of domains to allow for CORS requests. ONLY applies if the bucket is created by this module.  Valid values like: `http://api.example.com`, `https://foo.example.com`, or just `*`  Defaults to none
* `cors_allowed_headers` - Only used if cors_allowed_origins is not empty.  Headers to allow to be passed to the bucket. Defaults to `["*"]`
* `cors_allowed_methods` - Only used if cors_allowed_origins is not empty.  Valid values like: `GET`, `POST`, `PUT`. Defaults to `["GET", "HEAD", "OPTIONS"]`
* `default_ttl` - Override the default cache behavior default_ttl. Defaults to 0.
* `max_ttl` - Override the default cache behavior max_ttl. Defaults to 0.
* `min_ttl` - Override the default cache behavior min_ttl. Defaults to 0.

## Notes

Adding HSTS headers and root object resolution will create CloudFront functions to perform these tasks.  If you ever wish to _remove_ these features, you will need to manually disassociate the CloudFront functions from the cloufront distribution's default behavior.

## Contributing

We welcome contributions.
To contribute please read our [CONTRIBUTING](CONTRIBUTING.md) document.

All contributions are subject to the [license](LICENSE.md) and in no way imply compensation for contributions.

### Terraform 0.12

Our code base now exists in Terraform 0.13 and we are halting new features in the Terraform 0.12 major version.  If you wish to make a PR or merge upstream changes back into 0.12, please submit a PR to the `terraform-0.12` branch.

## Code of Conduct

We strive for a welcoming and inclusive environment for all SBA projects.

Please follow this guidelines in all interactions:

* Be Respectful: use welcoming and inclusive language.
* Assume best intentions: seek to understand other's opinions.

## Security Policy

Please do not submit an issue on GitHub for a security vulnerability.
Instead, contact the development team through [HQVulnerabilityManagement](mailto:HQVulnerabilityManagement@sba.gov).
Be sure to include **all** pertinent information.

The agency reserves the right to change this policy at any time.
