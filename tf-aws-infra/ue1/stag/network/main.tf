provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket = "tf-infra-aws"
    key    = "tf-aws-infra-appmakersla/ue1/stag/network/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
     // version = ">= 4.55"
      version =  ">= 4.0, < 6.0" 
    }
  }
  required_version = ">= 1.0"
}



locals {
  nat_gateways = {
    natgw_1 = {
      name      = "stag-natgw-1"
      subnet_id = module.vpc.public_subnets[0] 
    }
    natgw_2 = {
      name      = "stag-natgw-2"
      subnet_id = module.vpc.public_subnets[1] 
    }
  }
}


module "vpc" {
  source              = "../../../modules/network/vpc" 
  vpc_name            = "vpc-ue1-appmakers"            
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones  = var.availability_zones
  tags                = var.tags
}

module "internet_gateway" {
  source  = "../../../modules/network/internet_gateway"
  vpc_id  = module.vpc.vpc_id
  tags             = {
    "name"        =   "stag-nat-gateway",
    "terraform"   =   "true",
    "env"         =   "stag"
  }
}

module "nat_gateway" {
  source           = "../../../modules/network/nat_gateway"
  public_subnet_id = module.vpc.public_subnets[0]
  tags             = {
    "name"        =   "stag-nat-gateway",
    "terraform"   =   "true",
    "env"         =   "stag"
  }
}

module "route_tables" {
  source               = "../../../modules/network/route_tables"
  vpc_id               = module.vpc.vpc_id
  internet_gateway_id  = module.internet_gateway.internet_gateway_id
  nat_gateway_id       = module.nat_gateway.nat_gateway_id
  public_subnet_ids    = module.vpc.public_subnets
  private_subnet_ids   = module.vpc.private_subnets
  tags             = {
    "name"        =   "stag-route-tables",
    "terraform"   =   "true",
    "env"         =   "stag"
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

