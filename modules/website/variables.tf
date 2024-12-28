variable "aws_region" {
    description = "region in which the resources will be deployed"
    type        = string
}

variable "site_folder" {
    description = "folder containing the build files of the app"
    type        = string
}

variable "site_index_file" {
    description = "index file for the site"
    type        = string
}

variable "site_error_file" {
    description = "error file for the site"
    type        = string
}

variable "site_domain" {
    description = "domain name for the site & s3 bucket, both should match each other for cloudflare and aws to work together"
    type        = string
}

variable "cloudflare_api_token" {

    description = "The api token for cloudflare, recommended permissions: Zone.Page Rules, Zone.DNS"
    type        = string
}

variable "cloudflare_zone_id" {
    description = "zone id for the domain in cloudflare"
    type        = string
}