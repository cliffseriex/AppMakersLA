variable "public_subnet_id" {
  description = "The ID of the public subnet for the NAT Gateway"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}
 