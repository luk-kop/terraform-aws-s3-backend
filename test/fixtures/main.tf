module "test_backend" {
  source = "../../"

  bucket_name_prefix  = var.bucket_name_prefix
  dynamodb_table_name = var.dynamodb_table_name

  bucket_versioning_enabled = var.bucket_versioning_enabled
  bucket_logging_enabled    = var.bucket_logging_enabled
  object_versions_lifecycle = var.object_versions_lifecycle
  trusted_iam_identity_arn  = data.aws_caller_identity.current_user.arn
  bucket_objects_deletion   = var.bucket_objects_deletion

  tags = var.tags
}

data "aws_caller_identity" "current_user" {}

variable "bucket_name_prefix" {
  type    = string
  default = "terraform-state-dev"
}

variable "dynamodb_table_name" {
  type    = string
  default = "terraform-state-dev-lock"
}

variable "bucket_versioning_enabled" {
  type    = bool
  default = true
}

variable "bucket_logging_enabled" {
  type    = bool
  default = true
}

variable "object_versions_lifecycle" {
  type = object({
    enabled = bool
    days    = number
  })
  default = {
    enabled = true
    days    = 60
  }
}

variable "bucket_objects_deletion" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}

output "state_bucket_name" {
  value = module.test_backend.state_bucket_name
}

output "logs_bucket_name" {
  value = module.test_backend.logs_bucket_name
}