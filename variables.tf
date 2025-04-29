variable "candidate" {
  type        = string
  description = "Name of ce candidate"
}

variable "api_stage" {
  type        = string
  description = "API Gateway Deployment stage label"
  default     = "v1"
}

variable "quotes_external_api" {
  type        = string
  description = "External partner API endpoint provider of random quotes"
  default     = "https://dummyjson.com/quotes/random"
}

variable "ipinfo_external_api" {
  type        = string
  description = "External partner API endpoint provider of IP metadata"
  default     = "http://ip-api.com/json/"
}