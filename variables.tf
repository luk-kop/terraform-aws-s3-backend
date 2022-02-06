variable "bucket_name_prefix" {
  type    = string
  default = "terraform-state-dev-"
}

variable "dynamodb_table_name" {
  type    = string
  default = "terraform-state-lock"
}

variable "bucket_versioning" {
  type    = bool
  default = true
}

variable "trusted_iam_identity_arn" {
  type    = string
  default = null
}