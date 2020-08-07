# Terraform Simple Website

Sometimes you just want to get your simple static website up and running quickly.  And then you start to wonder about HTTPS, caching, logging, HSTS headers, Bucket Permissions, and so on.  Ain't nobody got time for that.  This handles that boilerplate for you and condenses the code into this:

```
module "static_site" {
  source = "USSBA/static-website/aws"
  version = "~> 1.0"

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

## Parameters

### Required

* `domain_name` - The domain name of your site
* `acm_certificate_arn` - The ACM cert matching your domain name to feed into cloudfront

### Optional

* `hosted_zone_id` - The hosted zone matching your domain; if provided, the module will create the Route53 recordset for you.  If not, you'll need to map the cloudfront DNS yourself
* `hsts_header` - The value of the HSTS header, eg `max-age=31536000`, helpful to let your users know you always want them using HTTPS.  With CloudFront, you need lambda@edge to do this, so... it will create it.
* `default_subdirectory_object` - If you want URLs ending in `/` to load a file, set this to something like `index.html`. With CloudFront, you need lambda@edge to do this, so... it will create it.

## Notes

Adding HSTS headers and root object resolution will create lambda-at-edge functions to perform these tasks around cloudfront.  If you ever wish to _remove_ these features, you will need to manually disassociate the lambda-at-edge functions from the cloufront distribution's default behavior.

## Contributing

We welcome contributions.
To contribute please read our [CONTRIBUTING](CONTRIBUTING.md) document.

All contributions are subject to the license and in no way imply compensation for contributions.

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
