
resource "aws_sqs_queue" "sqs_queue" {
  name                      = var.name
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
  #redrive_policy = jsonencode({
  #  deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
  #  maxReceiveCount     = 4
  #})

  tags = {
    Project         = "sr-de-test-${var.candidate}",
  }
}
