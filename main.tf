data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
locals {
  region  = data.aws_region.current.name
  account = data.aws_caller_identity.current.account_id
}

module "ddb_quotes" {
  source        = "./modules/dynamodb"
  candidate     = var.candidate
  hash_key      = "QuoteId"
  hash_key_type = "S"
  api           = "quotes"
}

module "ddb_ipinfo" {
  source        = "./modules/dynamodb"
  candidate     = var.candidate
  hash_key      = "query"
  hash_key_type = "S"
  api           = "ipinfo"
}

module "bucket" {
  source    = "./modules/bucket"
  candidate = var.candidate

}

module "result_bucket" {
  source    = "./modules/bucket"
  candidate = "${var.candidate}-results"

}

module "failure_bucket" {
  source    = "./modules/bucket"
  candidate = "${var.candidate}-failure"

}

module "trigger_bucket" {
  source    = "./modules/bucket"
  candidate = "${var.candidate}-trigger"

}

module "s3_trigger" {
  source               = "./modules/s3_trigger"
  bucket_arn           = module.trigger_bucket.arn
  bucket_id            = module.trigger_bucket.name
  lambda_arn           = module.validate_image.arn
  lambda_function_name = module.validate_image.function_name

  depends_on = [
    module.trigger_bucket,
    module.validate_image
  ]
}

######################################################################
### Success Queue
module "validate_success_queue" {
  source    = "./modules/sqs_queue"
  candidate = var.candidate
  name = "${var.candidate}-sr-de-test-success"
}

######################################################################
### Success Queue
module "validate_failure_queue" {
  source    = "./modules/sqs_queue"
  candidate = var.candidate
  name = "${var.candidate}-sr-de-test-failure"
}

######################################################################
### API Gateway
module "api" {
  source    = "./modules/api"
  candidate = var.candidate
}

######################################################################
### Global API Gateway Deployment and Stage
module "api_deployment" {
  source    = "./modules/api_deployment"

  api_id    = module.api.id
  api_stage = var.api_stage
  api_body  = module.api.body

  depends_on = [
    module.validate_image
  ]
}

######################################################################
### Validate Image Service

data "archive_file" "lambda_validate_image" {
  type = "zip"

  source_dir  = "${path.module}/src/validate_image"
  output_path = "${path.module}/src/validate_image.zip"
}

resource "aws_s3_object" "lambda_validate_image" {
  bucket = module.bucket.name

  key    = "validate_image.zip"
  source = data.archive_file.lambda_validate_image.output_path

  etag = filemd5(data.archive_file.lambda_validate_image.output_path)
}

module "validate_image" {
  source        = "./modules/lambda-api"
  api           = "validate_image"
  candidate     = var.candidate
  bucket        = module.bucket.name
  bucket_file   = aws_s3_object.lambda_validate_image.key
  runtime       = "python3.9"
  file_hash     = data.archive_file.lambda_validate_image.output_base64sha256
  api_id        = module.api.id
  resource_id   = module.api.root_resource_id
  api_exec_arn  = module.api.execution_arn
  trigger_arn   = module.trigger_bucket.arn

  policy = jsonencode({
    Version     = "2012-10-17"
    Statement   = [{
      Action    = [
        "dynamodb:*",
      ]
      Effect    = "Allow"
      Resource  = "*"
      }]
  })

  config_vars = {
      SUCCESS_QUEUE = module.validate_success_queue.url
      FAILURE_QUEUE = module.validate_failure_queue.url
      FAIL_BUCKET   = module.failure_bucket.name
    }

  depends_on = [
    module.validate_failure_queue,
    module.validate_success_queue,
    module.failure_bucket
  ]
}


