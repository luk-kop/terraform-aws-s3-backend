resource "aws_s3_bucket" "terraform_s3_state_bucket" {
  bucket_prefix = var.bucket_name_prefix
  acl           = "private"
  # On deletion remove all objects in S3 bucket
  force_destroy = true
  # Prevent accidental deletion of this S3 bucket
  # lifecycle {
  #   prevent_destroy = true
  # }

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

data "aws_iam_policy_document" "terraform_backend_access_policy" {
  statement {
    sid       = "DynamoDbStateLocking"
    actions   = ["dynamodb:GetItem", "dynamodb:DeleteItem", "dynamodb:PutItem"]
    resources = [aws_dynamodb_table.terraform_dynamodb_locks.arn]
  }
  statement {
    sid       = "ListStateBucket"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.terraform_s3_state_bucket.arn]
  }
  statement {
    sid       = "UpdateStateFile"
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["${aws_s3_bucket.terraform_s3_state_bucket.arn}/*"]
  }
}

data "aws_iam_policy_document" "terraform_backend_assume_role_policy" {
  statement {
    sid     = "GrantIAMIdentityAccessToTheRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.trusted_iam_identity_arn == null ? data.aws_caller_identity.current.arn : var.trusted_iam_identity_arn]
    }
  }
}

resource "aws_iam_role" "terraform_backend_iam_role" {
  name_prefix        = "terraform-backend-"
  description        = "Allows access to the terraform backend in S3 bucket and DynamoDB."
  assume_role_policy = data.aws_iam_policy_document.terraform_backend_assume_role_policy.json
  inline_policy {
    name   = "terraform-backend-access-policy"
    policy = data.aws_iam_policy_document.terraform_backend_access_policy.json
  }
}

data "aws_caller_identity" "current" {}