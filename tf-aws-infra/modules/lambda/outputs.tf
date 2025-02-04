
output "db_migration_lambda_arn" {
  description = "The ARN of the database migration Lambda"
  value       = aws_lambda_function.db_migration_lambda.arn
}

output "app_lambda_arn" {
  description = "The ARN of the application Lambda"
  value       = aws_lambda_function.app_lambda.arn
}
