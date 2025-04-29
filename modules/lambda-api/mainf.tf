resource "aws_lambda_function" "lambda" {
  function_name = "${var.candidate}-sr-ce-test-${var.api}"

  s3_bucket = var.bucket
  s3_key    = var.bucket_file

  runtime = var.runtime
  handler = "lambda_function.lambda_handler"
  timeout = 15

  source_code_hash = var.file_hash

  role = aws_iam_role.role.arn

  environment {
    variables = var.config_vars
  }

  tracing_config {
    mode = "Active"
  }
}

resource "aws_iam_role" "role" {
  name = "${var.candidate}-sr-ce-test-${var.api}-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "lambda.amazonaws.com",
            "apigateway.amazonaws.com"
          ]
        }
      }
    ]
  })
}



resource "aws_iam_role_policy_attachment" "exec_policy" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "policy" {
  name        = "${var.candidate}-${var.api}-lambda"
  description = "${var.api} lambda"

  policy = var.policy
}

data "aws_iam_policy_document" "bedrock_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["bedrock:*"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "s3_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = [
      "s3:GetObject",
      "s3:*"
    ]
    resources = ["arn:aws:s3:::*"]
  }
}

data "aws_iam_policy_document" "kms_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
      ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "bedrock_policy" {
  name        = "AllowBedrock"
  description = "Allow Bedrock policy"
  policy      = data.aws_iam_policy_document.bedrock_policy_doc.json
}

resource "aws_iam_policy" "s3_policy" {
  name        = "AllowS3"
  description = "Allow S3 policy"
  policy      = data.aws_iam_policy_document.s3_policy_doc.json
}

resource "aws_iam_policy" "kms_policy" {
  name        = "AllowKMS"
  description = "Allow KMS policy"
  policy      = data.aws_iam_policy_document.kms_policy_doc.json
}


resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "bedrock_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.bedrock_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "kms_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.kms_policy.arn
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = var.api_id
  parent_id   = var.resource_id
  path_part   = var.api
}

resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = var.api_id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = var.api_id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.id
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_exec_arn}/*"
}

resource "aws_lambda_permission" "allow_s3" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.trigger_arn
}
