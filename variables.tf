variable "acm_certificate_arn" {
  type        = string
  description = "Required: An ACM certificate ARN that will be associated with the CloudFront distribution."
}
variable "default_subdirectory_object" {
  type        = string
  description = "Optional: If you want all subdirectories to route `/` to a file, the lambda@edge infrastructure will be created to support this; ex: `index.html`"
  default     = ""
}
variable "domain_name" {
  type        = string
  description = "Required: A fully quialified domain name matching/valid for the ACM certificate."
}
variable "hosted_zone_id" {
  type        = string
  description = "Optional: Providing a Hosted Zone id will create an Route 53 Alias record pointing the `domain_name` at the CloudFront distribution."
  default     = ""
}
variable "hsts_header" {
  type        = string
  description = "Optional: If you want HSTS headers in front of your application, the lambda@edge infrastructure will be created to support this. Go to https://hstspreload.org/ for more information"
  default     = ""
}
variable "name_prefix" {
  type        = string
  description = "Required: Max of 6 characters; A name prefix for resources that require it."
  default     = "static"
}
variable "content_bucket_name" {
  type        = string
  description = "Optional: Provide a name for the content bucket.  By default, the content bucket name will be '<domain_name`>-static-content'."
  default     = ""
}
variable "create_content_bucket" {
  type        = bool
  description = "Optional: If the bucket already exists, set this to false, and the module will use the existing bucket"
  default     = true
}
variable "cloudfront_oai_id" {
  type        = string
  description = "Optional: If you already have an OAI created and don't want another one, provide the ID for it"
  default     = ""
}
variable "force_destroy_buckets" {
  type        = bool
  description = "Optional: If set to true, buckets will be deleted on module destroy, regardless of data in those buckets.  Defaults to false"
  default     = false
}
# Tags
variable "tags" {
  type        = map(any)
  description = "Optional; Map of key-value tags to apply to all applicable resources"
  default     = {}
}
variable "tags_s3_bucket_logging" {
  type        = map(any)
  description = "Optional; Map of additional key-value tags to apply to the s3 bucket containing logs"
  default     = {}
}
variable "tags_s3_bucket_content" {
  type        = map(any)
  description = "Optional; Map of additional key-value tags to apply to the s3 bucket containing the static website content"
  default     = {}
}
variable "tags_cloudfront" {
  type        = map(any)
  description = "Optional; Map of key-value tags to apply to the cloudfront distribution"
  default     = {}
}
