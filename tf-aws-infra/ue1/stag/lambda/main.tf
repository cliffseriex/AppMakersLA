provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "tf-infra-aws"
    key    = "tf-aws-infra-appmakersla/ue1/stag/lambda/terraform.tfstate"
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


data "aws_secretsmanager_secret_version" "my_secret_version" {
  secret_id = "db_password"  
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

data "aws_security_group" "lambda_sg" {
  filter {
    name   = "group-name"
    values = ["lambda-sg"]  
  }
}

module "alb" {
  source              = "../../../modules/network/alb"
  alb_name            = "lambda-alb"
  target_group_name   = "lambda-tg"
  security_group_id   = data.aws_security_group.lambda_sg.id
  private_subnet_ids  = [data.aws_subnet.stag_private_1.id, data.aws_subnet.stag_private_2.id]
  vpc_id              = data.aws_vpc.vpc-ue1.id
}


module "api_gateway" {
  source             = "../../../modules/api_gateway"    
  api_name           = "tasks-api-staging"
  vpc_link_name      = "lambda-vpc-link"
  security_group_id  = data.aws_security_group.lambda_sg.id
  private_subnet_ids = [data.aws_subnet.stag_private_1.id, data.aws_subnet.stag_private_2.id]
  alb_listener_arn   = module.alb.alb_listener_arn  
  stage_name         = "staging" 
}

module "lambda" {
  source              = "../../../modules/lambda"
  function_name       = "tasks-lambda-staging"
  handler             = "handler.lambda_handler"
  s3_bucket           = "tf-infra-aws"
  runtime             = "python3.9" 
  lambda_zip          = "app_lambda.zip"
  db_migration_zip    = "db_migration.zip"
  memory_size         = 256
  timeout             = 15

   api_gateway_arn = module.api_gateway.api_gateway_arn

  private_subnet_ids = [data.aws_subnet.stag_private_1.id, data.aws_subnet.stag_private_2.id]  
  lambda_security_group_id = data.aws_security_group.lambda_sg.id

  environment_variables = {
    DB_HOST     = "appmakers.cnwwewoekns0.us-east-1.rds.amazonaws.com"
    DB_NAME     = "appmakers"
    DB_USER     = "appmakers"
    DB_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.my_secret_version.secret_string)["s"]
    API_URL = module.api_gateway.stage_invoke_url
    SENTRY_DSN = "https://c7adb93db107ff22e48d501918bba88e@o4508728666685440.ingest.us.sentry.io/4508728671862784"
  }

  
}

