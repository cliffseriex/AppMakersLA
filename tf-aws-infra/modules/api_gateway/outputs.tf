output "stage_invoke_url" {
  description = "The invoke URL for the API Gateway stage"
  value       = aws_apigatewayv2_stage.stage.invoke_url
}

output "api_id" {
  description = "The ID of the API Gateway"
  value       = aws_apigatewayv2_api.api.id
}