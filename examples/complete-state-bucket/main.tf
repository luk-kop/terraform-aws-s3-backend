module "tf_state_backend" {
  source = "../../"

  bucket_name_prefix  = "tf-state-dev"
  dynamodb_table_name = "tf-state-dev-lock"

  bucket_versioning_enabled = true
  bucket_logging_enabled    = true
  object_versions_lifecycle = {
    enabled = true
    days    = 30
  }
  trusted_iam_identity_arn = data.aws_caller_identity.current_user.arn
  bucket_objects_deletion  = true

  tags = {
    Terraform   = "true",
    Environment = "dev"
  }
}

data "aws_caller_identity" "current_user" {}