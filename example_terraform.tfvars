# Example terraform.tfvars file

# AWS region (AWS region to deploy the infrastructure)
aws_region = "ap-south-1"

# Frontend Static Site Folder (Static files)
site_folder = "out"

# Static Site Index and Error File
site_index_file = "index.html"
site_error_file = "error.html"

# Domain Name
site_domain = "www.example.com"

# Cloudflare API Token
# Recommended Permissions: Zone.Page Rules, Zone.DNS
cloudflare_api_token = "---"

# Cloudflare Zone ID
cloudflare_zone_id = "---"