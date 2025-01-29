output "rds_endpoint" {
  description = "The RDS PostgreSQL endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_port" {
  description = "The RDS PostgreSQL port"
  value       = module.rds.rds_port
}

output "cloudwatch_alarm_arn" {
  description = "The ARN of the CloudWatch alarm"
  value       = module.cloudwatch.alarm_arn
}
