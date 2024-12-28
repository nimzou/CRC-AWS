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

# IaM Role to Allow Lambda to access DynamoDB

resource "aws_iam_role" "AllowDynamoDbAccess" {
  name = "AllowDynamoDbAccess"
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "dynamodb_access"
  role = aws_iam_role.AllowDynamoDbAccess.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "dynamodb:GetItem",
        "dynamodb:PutItem"
      ]
      Resource = aws_dynamodb_table.countdb.arn
    }]
  })
}

# Lambda Function

data "archive_file" "lambda_function" {
  type = "zip"
  source_file = "${path.module}/function.py"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "count_function" {
  function_name = "count_function"
  filename = "${path.module}/lambda_function.zip"
  role = aws_iam_role.AllowDynamoDbAccess.arn
  runtime = "python3.12"
  handler = "function.handler"
  architectures = ["x86_64"]
}

resource "aws_lambda_function_url" "count_function" {
  function_name = aws_lambda_function.count_function.function_name
  authorization_type = "NONE"
  cors {
    allow_credentials = true
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["Content-Type"]
    expose_headers = ["Content-Type"]
    max_age = 0
  }
}