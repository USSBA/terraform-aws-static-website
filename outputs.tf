output "content_bucket_id" {
  value       = local.content_bucket.id
  description = "The id of the S3 Bucket where you will put your static html content.  CloudFront will handle requests and fetch data from this bucket.  Depending on your settings, this could be made by the module, or it could be the bucket ID passed in by variable"
}
output "content_bucket_arn" {
  value       = local.content_bucket.arn
  description = "The ARN of the S3 Bucket where you will put your static html content.  CloudFront will handle requests and fetch data from this bucket.  Depending on your settings, this could be made by the module, or it could be the bucket ID passed in by variable"
}

output "cloudfront_distribution" {
  value       = module.cloudfront.distribution
  description = "The cloudfront distribution proxying requests to the content bucket"
}

output "cloudfront_oai_id" {
  value       = local.cloudfront_oai_id
  description = "The Origin Access Identity used by CloudFront to access your Bucket.  This normally is not needed, but if you configure this module to NOT manage bucket policy (possibly because you have other uses for your content bucket), you will need to use this OAI ID to grant s3:GetObject access on your bucket."
}
output "cloudfront_oai_iam_arn" {
  value       = local.cloudfront_oai_iam_arn
  description = "The IAM ARN of the Origin Access Identity used by CloudFront to access your Bucket.  This normally is not needed, but if you configure this module to NOT manage bucket policy (possibly because you have other uses for your content bucket), you will need to use this OAI iam_arn to grant s3:GetObject access on your bucket."
}
