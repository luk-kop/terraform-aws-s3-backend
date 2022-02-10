# Terraform remote S3 state backend

[![Terraform](https://img.shields.io/badge/Terraform-1.0.0-blueviolet.svg)](https://www.terraform.io/)

> Terraform module which set up state backend using AWS S3 and DynamoDB services.

## Usage

```hcl
module "tf_s3_state_backend" {
  source = "../../"

  bucket_name_prefix  = "tf-state-dev"
  dynamodb_table_name = "tf-state-dev-lock"

  bucket_versioning_enabled = true
  bucket_logging_enabled    = true
  object_versions_lifecycle = {
    enabled = true
    days    = 30
  }
  trusted_iam_identity_arn = "arn:aws:iam::123456789012:user/example-user"
  bucket_objects_deletion  = true

  tags = {
    Terraform   = "true",
    Environment = "dev"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](https://releases.hashicorp.com/terraform/1.0.0/) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](https://registry.terraform.io/providers/hashicorp/aws/4.0.0) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](https://registry.terraform.io/providers/hashicorp/aws/4.0.0) | >= 4.0 |
