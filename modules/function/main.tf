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

# REST API Gateway

resource "aws_api_gateway_rest_api" "lambda-api" {
  name = "lambda-api"
  endpoint_configuration {
    types = [ "EDGE" ]
  }
}

resource "aws_api_gateway_resource" "trigger" {
  rest_api_id = aws_api_gateway_rest_api.lambda-api.id
  parent_id = aws_api_gateway_rest_api.lambda-api.root_resource_id
  path_part = "visit-count-api"
}

resource "aws_api_gateway_method" "trigger" {
  rest_api_id = aws_api_gateway_rest_api.lambda-api.id
  resource_id = aws_api_gateway_resource.trigger.id
  http_method = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.lambda-api.id
  resource_id = aws_api_gateway_resource.trigger.id
  http_method = aws_api_gateway_method.trigger.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.count_function.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id = "AllowAPIGatewayInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.count_function.function_name
  principal = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.lambda-api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.lambda-api.id
  depends_on = [
    aws_api_gateway_integration.lambda
  ]
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.lambda.id
  rest_api_id = aws_api_gateway_rest_api.lambda-api.id
  stage_name = "prod"
}

output "api_gateway_invoke_url" {
  description = "API Gateway stage invoke URL"
  value = "${aws_api_gateway_stage.prod.invoke_url}/${aws_api_gateway_resource.trigger.path_part}"
}