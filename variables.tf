variable "hosted_zone_id" {
  type = string
  default = ""
  description = "Optional: this will create a route53 record if you provide a hosted zone id"
}
variable "acm_certificate_arn" {
  type = string
}
variable "domain_name" {
  type = string
}

variable "hsts_header" {
  type = string
  description = "Optional: If you want HSTS headers in front of your application, the lambda@edge infrastructure will be created to support this. Go to https://hstspreload.org/ for more information"
  default = ""
}

variable "default_subdirectory_object" {
  type = string
  description = "Optional: If you want all subdirectories to route `/` to a file, the lambda@edge infrastructure will be created to support this; ex: `index.html`"
  default = ""
}

variable "name_prefix" {
  type = string
  description = "A name prefix for resources that require it.  Max 6 characters"
  default = "static"
}

