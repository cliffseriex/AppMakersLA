variable "role_name" {
  description = "The name of the IAM role for RDS monitoring"
  type        = string
  default     = "rds-monitoring-role"
}

variable "tags" {
  description = "Tags for the IAM resources"
  type        = map(string)
}

