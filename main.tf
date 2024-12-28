module "website" {
    source = "./modules/website"

    aws_region           = var.aws_region
    site_folder          = var.site_folder
    site_index_file      = var.site_index_file
    site_error_file      = var.site_error_file
    site_domain          = var.site_domain
    cloudflare_api_token = var.cloudflare_api_token
    cloudflare_zone_id   = var.cloudflare_zone_id
}

module "function" {
    source              = "./modules/function"
    aws_region          = var.aws_region
}