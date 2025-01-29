variable "rds_instance_id" {
  description = "The ID of the RDS instance to monitor"
  type        = string
}

variable "sns_email_address" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
}

variable "tags" {
  description = "Tags for the CloudWatch resources"
  type        = map(string)
}
