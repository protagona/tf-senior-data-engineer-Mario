resource "aws_s3_bucket" "bucket" {
  bucket = "protagona-sr-ce-test-${lower(var.candidate)}"

  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.bucket]

  bucket = aws_s3_bucket.bucket.id
  acl    = "private"
}



resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "kmskey" {
  #checkov:skip=CKV_AWS_7
  #checkov:skip=CKV2_AWS_64
  description             = "Key used to encrypt bucket ${aws_s3_bucket.bucket.id}"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sseconfig" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kmskey.arn
      sse_algorithm     = "aws:kms"
    }
  }
}
