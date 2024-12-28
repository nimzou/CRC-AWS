variable "aws_region" {
  description = "The region in which the resources will be deployed"
  type        = string
}

variable "site_folder" {
  description = "The folder containing all the site files, don't keep any sensitive files here"
  type        = string
}

variable "site_index_file" {
  description = "The index file for the site"
  type        = string
}

variable "site_error_file" {
  description = "The error file for the site"
  type        = string
}

variable "site_domain" {
  type        = string
  description = "The domain name for the site. Also used for the s3 bucket name. Both should match for cloudflare and aws to work together according to the docs."
}

variable "cloudflare_api_token" {
  type        = string
  description = "The api token for cloudflare, recommended permissions: Zone.Page Rules, Zone.DNS"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "The zone id for the domain in cloudflare"
}
