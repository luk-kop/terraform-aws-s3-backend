variable "main_region" {
  type = string
}

variable "bucket_name_prefix" {
  type    = string
  default = "terraform-backend-"
}

variable "bucket_versioning" {
  type    = bool
  default = true
}