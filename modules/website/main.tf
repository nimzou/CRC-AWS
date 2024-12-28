terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.73.0"
        }
        cloudflare = {
            source = "cloudflare/cloudflare"
            version = "4.45.0"
        }
    }
}

provider "aws" {
    region = var.aws_region
}

provider "cloudflare" {
    api_token = var.cloudflare_api_token
}

module "static_files" {
    source = "hashicorp/dir/template"
    version = "1.0.2"
    base_dir = "${path.root}/${var.site_folder}"
}

# S3 bucket for www subdomain

resource "aws_s3_bucket" "www"{
    bucket = "${var.site_domain}"
    force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "www" {
    bucket = aws_s3_bucket.www.id
    index_document {
        suffix = var.site_index_file
    }
    error_document {
        key = var.site_error_file
    }
    depends_on = [ aws_s3_bucket.www ]
}

resource "aws_s3_bucket_public_access_block" "www" {
    bucket = aws_s3_bucket.www.id
    block_public_acls = false
    block_public_policy = false
    ignore_public_acls = false
    restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "www" {
    bucket = aws_s3_bucket.www.id
    rule {
        object_ownership = "BucketOwnerPreferred"
    }
}

resource "aws_s3_bucket_policy" "www" {
    bucket = aws_s3_bucket.www.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "PublicReadGetObject"
                Effect = "Allow"
                Principal = "*"
                Action = "s3:GetObject"
                Resource = [
                    aws_s3_bucket.www.arn,
                    "${aws_s3_bucket.www.arn}/*"
                ]
            }
        ]
    })
    depends_on = [ aws_s3_bucket_public_access_block.www ]
}

resource "aws_s3_object" "www" {
    for_each = module.static_files.files
    bucket = aws_s3_bucket.www.id
    key = each.key
    content_type = each.value.content_type
    source = each.value.source_path
    depends_on = [ aws_s3_bucket.www ]
}

# Cloudflare DNS

resource "cloudflare_record" "www" {
    zone_id = var.cloudflare_zone_id
    name = "www"
    content = aws_s3_bucket_website_configuration.www.website_endpoint
    type = "CNAME"
    proxied = true
    depends_on = [
        aws_s3_bucket.www,
        aws_s3_bucket_website_configuration.www,
    ]
}

resource "cloudflare_page_rule" "https" {
    zone_id = var.cloudflare_zone_id
    target = "*.${var.site_domain}/*"
    actions {
        always_use_https = true
    }
    depends_on = [ cloudflare_record.www ]
}