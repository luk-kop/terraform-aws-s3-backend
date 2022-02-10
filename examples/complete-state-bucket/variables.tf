variable "region" {
  type        = string
  description = "AWS region in which resources will be deployed"
  default     = "eu-west-1"
}

variable "profile" {
  description = "AWS profile used to deploy resources"
  type        = string
  default     = "default"
}