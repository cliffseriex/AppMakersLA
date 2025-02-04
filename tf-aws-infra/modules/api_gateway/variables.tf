variable "api_name" {
  description = "The name of the API"
  type        = string
}

variable "stage_name" {
  description = "The name of the API Gateway stage"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where Lambda is deployed"
  type        = list(string)
}

variable "vpc_link_name" {}
variable "security_group_id" {}
variable "alb_listener_arn" {}

