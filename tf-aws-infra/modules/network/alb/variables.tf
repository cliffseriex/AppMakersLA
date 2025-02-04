variable "alb_name" {}
variable "target_group_name" {}
variable "security_group_id" {}
variable "private_subnet_ids" { type = list(string) }
variable "vpc_id" {}
