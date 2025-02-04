resource "aws_vpc" "main" {   
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
    tags = merge(var.tags, {
    "Name" = var.vpc_name,
    "terraform" = "true"
  })
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { 
    "Name" = "stag-public-subnet-${count.index + 1}",
    "env"  = "stag",
    "terraform" = "true"
  })
} 

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = merge(var.tags, { 
    "Name" = "stag-private-subnet-${count.index + 1}",
    "env"  = "stag",
    "terraform" = "true"
  })
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_subnets" {
  value = aws_subnet.public[*].id
} 

output "private_subnets" {
  value = aws_subnet.private[*].id
}
