output "content_bucket_id" {
  value       = aws_s3_bucket.static.id
  description = "The bucket where you will put your static html content"
}
