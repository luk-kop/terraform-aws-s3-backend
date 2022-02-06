provider "aws" {
  region = var.main_region
}

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
    Environment = "dev"
  }
}