resource "aws_s3_bucket" "terraform_s3_state_bucket" {
  bucket_prefix = var.bucket_name_prefix
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = var.bucket_versioning
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Tool        = "terraform"
    Environment = var.tag_environment
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_s3_state_bucket_public_access" {
  bucket                  = aws_s3_bucket.terraform_s3_state_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_dynamodb_locks" {
  name           = var.dynamodb_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}