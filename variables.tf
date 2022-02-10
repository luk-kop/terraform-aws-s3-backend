variable "bucket_name_prefix" {
  description = "Terraform state bucket's name prefix"
  type        = string
  default     = "terraform-state-dev"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name used for state locking."
  type        = string
  default     = "terraform-state-lock"
}

variable "bucket_versioning" {
  description = "Enable Terraform state bucket versioning."
  type        = bool
  default     = true
}

variable "trusted_iam_identity_arn" {
  description = "ARN of IAM identity allowed to assume the Terraform backend role."
  type        = string
  default     = "current-user"
  validation {
    condition     = can(regex("(^arn:aws:iam::[0-9]{12}:(user|group|role/.+)|root)|(^current-user$)", var.trusted_iam_identity_arn))
    error_message = "The trusted_iam_identity_arn must be a valid IAM ARN."
  }
}

variable "tags" {
  description = "Tags to set for all resources."
  type        = map(string)
  default     = {}
}

variable "bucket_objects_deletion" {
  description = "Allow bucket delection with objects inside on resource destroy action."
  type        = bool
  default     = false
}

variable "logging_enabled" {
  description = "Enable bucket logging for Terraform state bucket."
  type        = bool
  default     = true
}