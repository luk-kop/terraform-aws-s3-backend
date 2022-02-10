output "state_bucket_arn" {
  value       = aws_s3_bucket.terraform_state_bucket.arn
  description = "The ARN of the S3 bucket in which the Terraform state file will be stored."
}

output "state_bucket_name" {
  value       = aws_s3_bucket.terraform_state_bucket.id
  description = "The name of the S3 bucket in which the Terraform state file will be stored."
}

output "logs_bucket_name" {
  value       = var.bucket_logging_enabled ? aws_s3_bucket.terraform_logs_bucket[0].id : null
  description = "The name of the S3 bucket that will receive the logs Terraform from state bucket."
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_dynamodb_locks.name
  description = "The name of the DynamoDB table used for Terraform state locking and consistency."
}

output "iam_role_arn" {
  value       = aws_iam_role.terraform_backend_iam_role.arn
  description = "The IAM Role ARN to assume."
}