variable "api_name" {
  description = "The name of the API"
  type        = string
}

variable "lambda_arn" {
  description = "The ARN of the Lambda function"
  type        = string
}

variable "stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
}
