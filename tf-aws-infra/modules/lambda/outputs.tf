output "lambda_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.lambda.arn
}

output "lambda_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.lambda.function_name
}
