# Releases

## v4.0.0

- **BREAKING**: Allowing optional bucket policy.  This will remove/recreate the existing bucket policy resource, but should have little impact.  Since resources are being moved, this is considered breaking

## v3.3.2

- BUGFIX: OPTIONS is not a supported CORS verb in S3

## v3.3.1

- BUGFIX: CORS forwarded headers

## v3.3.0

- Configurable cloudfront methods using `cloudfront_allowed_methods`.  Valid options are "get", "get_options", "all"
- Configurable CORS rule when bucket is created by the module

## v3.2.0

- Added tagging framework
- Added example directory with a simple example including tagging

## v3.1.0

- Option for force_destroy_buckets
- Bump `versions.tf` to support tf 0.14+

## v3.0.0

- Refactor bucket creation
- Default origin of CloudFront will change, but shouldn't have much impact
- **BREAKING**: Rename bucket resource, allow conditional creation
- **BREAKING**: Allow provided CloudFront OAI ID to skip creation of new OAI
- To migrate breaking changes, run:

```shell
terraform state mv module.<module-name>.aws_s3_bucket.static module.<module-name>.aws_s3_bucket.content[0]
terraform state mv module.<module-name>.aws_s3_bucket_policy.static module.<module-name>.aws_s3_bucket_policy.content
terraform state mv module.<module-name>.aws_cloudfront_origin_access_identity.oai module.<module-name>.aws_cloudfront_origin_access_identity.oai[0]
```

## v2.1.0

- Add bucket name to outputs

## v2.0.0

- Terraform v0.13 Upgrade

## v1.0.0

- Initial Release
