
variable "bucket_id" {
  type        = string
  description = "ID of the triggering bucket"
}

variable "bucket_arn" {
  type        = string
  description = "ARN of the triggering bucket"
}

variable "lambda_arn" {
  type        = string
  description = "ARN of the Lambda to trigger"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function to trigger"
}
