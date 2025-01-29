variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.50.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.50.0.0/24", "10.50.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.50.2.0/24", "10.50.3.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}
 
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    "Environment" = "staging"
    "ManagedBy"   = "Terraform"
  }
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}