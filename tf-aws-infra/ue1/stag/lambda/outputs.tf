output "lambda_arn" {
  description = "The ARN of the Lambda function"
  value       = module.lambda.lambda_arn
}

output "api_endpoint" {
  description = "The API Gateway endpoint"
  value       = module.api_gateway.stage_invoke_url
}
