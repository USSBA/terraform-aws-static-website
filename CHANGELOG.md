# Releases

## v3.0.0

- Refactor bucket creation
- BREAKING: Rename bucket resource, allow conditional creation
  - To migrate, run:

```shell
terraform state mv module.<module-name>.aws_s3_bucket.static module.<module-name>.aws_s3_bucket.content[0]`
terraform state mv module.<module-name>.aws_s3_bucket_policy.static module.<module-name>.aws_s3_bucket_policy.content`
```

- Default origin of CloudFront will change, but shouldn't have much impact

## v2.1.0

- Add bucket name to outputs

## v2.0.0

- Terraform v0.13 Upgrade

## v1.0.0

- Initial Release
