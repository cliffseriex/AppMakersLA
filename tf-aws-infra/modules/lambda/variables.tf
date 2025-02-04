

variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "runtime" {
  description = "Runtime environment for Lambda"
  type        = string
  default     = "python3.9"
}

variable "handler" {
  description = "Lambda function handler"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket containing Lambda ZIP"
  type        = string
}

variable "lambda_zip" {
  description = "S3 key for the main application Lambda"
  type        = string
}

variable "db_migration_zip" {
  description = "S3 key for the DB migration Lambda"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
}

variable "memory_size" {
  description = "Memory allocated to Lambda"
  type        = number
  default     = 128
}

variable "timeout" {
  description = "Timeout for Lambda function"
  type        = number
  default     = 10
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where Lambda will run"
  type        = list(string)
}

variable "lambda_security_group_id" {
  description = "Security group for Lambda networking"
  type        = string
}

variable "api_gateway_arn" {
  description = "Full ARN for API Gateway"
  type        = string
}

