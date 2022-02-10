variable "bucket_name_prefix" {
  description = "Terraform state bucket's name prefix."
  type        = string
  default     = "terraform-state-dev"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name used for state locking."
  type        = string
  default     = "terraform-state-dev-lock"
}

variable "bucket_versioning_enabled" {
  description = "Enable Terraform state bucket versioning."
  type        = bool
  default     = true
}

variable "bucket_logging_enabled" {
  description = "Enable Terraform state bucket logging. The dedicated logging bucket is created."
  type        = bool
  default     = true
}

variable "object_versions_lifecycle" {
  description = "Noncurrect state file versions expiration policy. Works only when bucket versioning is enabled."
  type = object({
    enabled = bool
    days    = number
  })
  default = {
    enabled = true
    days    = 60
  }
}

variable "trusted_iam_identity_arn" {
  description = "ARN of IAM identity allowed to assume the Terraform backend role. If omitted, caller identity ARN is used."
  type        = string
  default     = "current-user"
  validation {
    condition     = can(regex("(^arn:aws:iam::[0-9]{12}:(user|group|role/.+)|root)|(^current-user$)", var.trusted_iam_identity_arn))
    error_message = "The trusted_iam_identity_arn must be a valid IAM ARN."
  }
}

variable "bucket_objects_deletion" {
  description = "Allow bucket delection with objects inside on resource destroy action."
  type        = bool
  default     = false
}
variable "tags" {
  description = "Tags to set for all resources."
  type        = map(string)
  default     = {}
}