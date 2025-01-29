resource "aws_eip" "nat" {
  domain = "vpc" 
  tags = merge(var.tags, { "Name" = "nat-eip" })
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_id
  tags          = merge(var.tags, { "Name" = "nat-gateway" })
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}
 