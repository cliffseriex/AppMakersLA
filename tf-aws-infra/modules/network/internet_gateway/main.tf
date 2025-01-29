resource "aws_internet_gateway" "main" {
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { "Name" = "internet-gateway" })
} 

output "internet_gateway_id" {
  value = aws_internet_gateway.main.id
}
