variable "acm_certificate_arn" {
  type        = string
  description = "Required: An ACM certificate ARN that will be associated with the CloudFront distribution."
}
variable "default_subdirectory_object" {
  type        = string
  description = "If you want all subdirectories to route `/` to a file, the CloudFront function will be created to support this; ex: `index.html`"
  default     = "index.html"
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
  description = "Optional: If you want HSTS headers in front of your application, the CloudFront function will be created to support this. Enabled by default. Go to https://hstspreload.org/ for more information"
  default     = "max-age=31536000"
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
variable "manage_content_bucket_policy" {
  type        = bool
  description = "Optional: If you want to manage the bucket policy external to this module, set this to false.  In that case, you will be responsible for configuring the bucket to allow the OAI to read from the bucket."
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
variable "index_redirect" {
  type        = bool
  description = "Match any '/' that occurs at the end of a URI. Replace it with a default index"
  default     = true
}
variable "index_redirect_no_extension" {
  type        = bool
  description = "Match any URL that ends in /<something-without-a-dot>; append /index.html. Example example.com/foo/bar => example.com/foo/bar/index.html"
  default     = true
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

variable "cloudfront_allowed_methods" {
  type        = string
  description = "Optional; Configure the allowed_methods of cloudfront.  Allowed values are 'get', 'get_options', 'all'.  For more information, see AWS documentation: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-cloudfront-distribution-defaultcachebehavior.html#cfn-cloudfront-distribution-defaultcachebehavior-allowedmethods"
  default     = "all"
}

# CORS Config
variable "cors_allowed_origins" {
  type        = list(string)
  description = "Optional; List of domains to allow for CORS requests. ONLY applies if the bucket is created by this module.  Valid values like: http://api.example.com, https://foo.example.com, or just '*'  Defaults to none"
  default     = []
}
variable "cors_allowed_headers" {
  type        = list(string)
  description = "Optional; Only used if cors_allowed_origins is not empty.  Headers to allow to be passed to the bucket. Defaults to '*'"
  default     = ["*"]
}
variable "cors_allowed_methods" {
  type        = list(string)
  description = "Optional; Only used if cors_allowed_origins is not empty.  Valid values like: 'GET', 'POST', 'PUT'. Defaults to ['GET', 'HEAD', 'OPTIONS']"
  default     = ["GET", "HEAD"]
}

# Default Cache Behavior Cache Settings
variable "default_ttl" {
  type        = number
  description = "Optional; The default cache behavior default_ttl. Defaults to 0"
  default     = 0
}
variable "min_ttl" {
  type        = number
  description = "Optional; The default cache behavior min_ttl. Defaults to 0"
  default     = 0
}
variable "max_ttl" {
  type        = number
  description = "Optional; The default cache behavior max_ttl. Defaults to 0"
  default     = 0
}

