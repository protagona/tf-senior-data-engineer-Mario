######################################################################
### Quotes DynamoDB Table

resource "aws_dynamodb_table" "table" {
  name           = "${var.candidate}-${var.api}-sr-ce-test"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = var.hash_key

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }
}