
provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "tf-infra-aws"
    key    = "tf-aws-infra-appmakersla/ue1/stag/rds/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
     // version = ">= 4.55"
      version =  ">= 3.0, < 6.0" 
    }
  }
  required_version = ">= 1.0"
}


data "aws_vpc" "vpc-ue1" {
  filter {
    name   = "tag:Name"
    values = ["vpc-ue1"]
  }
}

data "aws_subnet" "stag_public_1" {
  filter {
    name   = "tag:Name"
    values = ["stag-public-subnet-1"]
  }
}

data "aws_subnet" "stag_private_1" {
  filter {
    name   = "tag:Name"
    values = ["stag-private-subnet-1"]
  }
}

data "aws_subnet" "stag_private_2" {
  filter {
    name   = "tag:Name"
    values = ["stag-private-subnet-2"]
  }
}


data "aws_secretsmanager_secret_version" "my_secret_version" {
  secret_id = "db_password"  
}
module "iam" {
  source = "../../../modules/iam"
  tags = {
    "env" = "stag"
  }
}

module "cloudwatch" {
  source            = "../../../modules/cloudwatch"
  rds_instance_id   = module.rds.rds_id
  sns_email_address = "cliffseriex@gmail.com"
  tags              = var.common_tags
}

module "rds" {
  source                = "../../../modules/rds"
  db_identifier         = "appmakers"
  allocated_storage     = 20
  max_allocated_storage = 100
  engine_version        = "15.10"
  instance_class        = "db.t4g.micro"
  username              = "appmakers"
  password              = jsondecode(data.aws_secretsmanager_secret_version.my_secret_version.secret_string)["db_password"]
  db_name               = "appmakers"
  multi_az              = true
  private_subnet_ids    = [data.aws_subnet.stag_private_1.id, data.aws_subnet.stag_private_2.id]
  vpc_id                = data.aws_vpc.vpc-ue1.id
  tags                  = var.common_tags  
  backup_retention_period = 7
  skip_final_snapshot   = true
  monitoring_interval   = 60
  monitoring_role_arn   = module.iam.monitoring_role_arn
}