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
