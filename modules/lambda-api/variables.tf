variable "candidate" {
  type        = string
  description = "Name of the candidate"
}

variable "bucket" {
  type        = string
  description = "Name of the bucket storing our lambda function package"
}

variable "bucket_file" {
  type        = string
  description = "Name of the lambda function zip file artifact"
}

variable "runtime" {
  type        = string
  description = "Target lambda function runtime"
}

variable "file_hash" {
  type        = string
  description = "MD5 hash of the zip file containing the lambda function"
}

variable "api_id" {
  type        = string
  description = "ID of the API Gateway to associate the lambda function"
}

variable "resource_id" {
  type        = string
  description = ""
}

variable "api_exec_arn" {
  type        = string
  description = ""
}

variable "policy" {
  type        = string
  description = "The json-formatted policy that the lambda function will use"
}

variable "config_vars" {
  type        = any
  description = "A collection of environment variables in the form of key/value pairs"
}

variable "api" {
    type      = string
    description = "The name of the API enpoint"
}

variable "trigger_arn" {
    type      = string
    description = "ARN of the triggering s3 bucket"
}
