
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {
    Environment = "staging"
    ManagedBy   = "Terraform"
  }
}
