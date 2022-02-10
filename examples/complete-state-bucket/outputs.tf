output "tf_state_dynamodb_name" {
  value = module.tf_state_backend.dynamodb_table_name
}

output "tf_state_bucket_name" {
  value = module.tf_state_backend.state_bucket_name
}

output "tf_logs_bucket_name" {
  value = module.tf_state_backend.logs_bucket_name
}

output "tf_iam_role_arn" {
  value = module.tf_state_backend.iam_role_arn
}