output "s3_bucket_arn" {
  value       = aws_s3_bucket.terraform_s3_state_bucket.arn
  description = "The ARN of S3 bucket in which the state file will be stored."
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_s3_state_bucket.id
  description = "The name of S3 bucket in which the state file will be stored."
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_dynamodb_locks.name
  description = "The name of DynamoDB table used for state locking and consistency."
}

output "iam_role_arn" {
  value       = aws_iam_role.terraform_backend_iam_role.arn
  description = "The IAM Role ARN to assume."
}