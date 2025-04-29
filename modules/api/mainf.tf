resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.candidate}-sr-ce-test-api-gateway"
  description = "API Gateway for ${var.candidate}-sr-ce-test"

  lifecycle {
      create_before_destroy = true
  }
}