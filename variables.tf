// Suggested:
// ${env}-${subdomain}-${domain}-${tld}
variable "name" {
  type        = string
  description = "AWS S3 Bucket. {env}-{name}"
}

variable "default_tags" {
  type    = map(string)
  default = {}
}

variable "price_class" {
  type = string
  default = "PriceClass_All" # PriceClass_All, PriceClass_200, PriceClass_100
}

variable "aliases" {
  type        = list(string)
  description = "Cloudfront Aliases"
}

variable "acm_certificate_arn" {
  type    = string
  default = ""
}

variable "web_acl_id" {
  type        = string
  default     = ""
  description = "WAF ACL ID"
}

variable "cors_origins" {
  type    = list(string)
  default = [
    "*"]
}

variable "origin_path" {
  type = string
  default = "/"
}

variable "origins" {
  type = list(any)
  default = []
}

// brotoli is not supported, set to false if doing self compression
variable "compress" {
  type = bool
  default = true
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

# lambda@edge
variable "lambda" {
  type    = map(string)
  default = {}
}

variable "error_codes" {
  type    = map(string)
  default = {}
}

variable "forward_headers" {
  type = list(string)
  default = [
    "Authorization",
    "Accept",
    "Accept-Charset",
    "Accept-Encoding",
    "Accept-Language",
    "Content-Length",
    "Content-Type",
    "Content-Encoding",
    "Content-Language",
    "Cache-Control",
  ]
}

variable "logging_bucket" {
  type    = string
  default = ""
}

// Override S3 bucket used
variable "bucket_domain_name" {
  default = ""
}

