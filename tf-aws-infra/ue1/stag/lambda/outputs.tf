
output "api_endpoint" {
  description = "The API Gateway endpoint"
  value       = module.api_gateway.stage_invoke_url
}
output "app_lambda_arn" {
  description = "ARN of the Application Lambda"
  value       = try(module.lambda.app_lambda_arn, null)
}

output "db_migration_lambda_arn" {
  description = "ARN of the Database Migration Lambda"
  value       = try(module.lambda.db_migration_lambda_arn, null)
}

