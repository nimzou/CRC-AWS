terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.73.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# DynamoDB Table & Table Item

resource "aws_dynamodb_table" "countdb" {
    name = "countdb"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "id"
    attribute {
      name = "id"
      type = "S"
    }
}

resource "aws_dynamodb_table_item" "countdb" {
    table_name = aws_dynamodb_table.countdb.name
    hash_key = aws_dynamodb_table.countdb.hash_key
  item = <<ITEM
  {
    "id": {"S": "1"},
    "views": {"N": "1"}
  }
  ITEM
}

