variable "db_identifier" {
  description = "Unique identifier for the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in GBs"
  type        = number
}

variable "max_allocated_storage" {
  description = "The maximum storage for the database"
  type        = number
}

variable "engine_version" {
  description = "The database engine version"
  type        = string
}

variable "instance_class" {
  description = "The instance class for the database"
  type        = string
}

variable "username" {
  description = "The master username for the database"
  type        = string
}

variable "password" {
  description = "The master password for the database"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = true
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS instance"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance is deployed"
  type        = string
}

variable "backup_retention_period" {
  description = "The number of days to retain backups"
  type        = number
  default     = 7
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on deletion"
  type        = bool
  default     = true
}

variable "monitoring_interval" {
  description = "Enhanced monitoring interval in seconds"
  type        = number
  default     = 60
}

variable "monitoring_role_arn" {
  description = "IAM Role ARN for Enhanced Monitoring"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
