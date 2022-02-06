provider "aws" {
  region = var.main_region
}

resource "aws_s3_bucket" "s3_state_bucket" {
  bucket_prefix = var.bucket_name_prefix
  acl           = "private"

  versioning {
    enabled = var.bucket_versioning
  }

  tags = {
    Tool        = "terraform"
    Environment = "dev"
  }
}