variable "bucket_name_prefix" {
  type    = string
  default = "terraform-state-dev-"
}

variable "dynamodb_table_name" {
  type    = string
  default = "terraform-lock"
}

variable "bucket_versioning" {
  type    = bool
  default = true
}

variable "tag_environment" {
  type    = string
  default = "dev"
}