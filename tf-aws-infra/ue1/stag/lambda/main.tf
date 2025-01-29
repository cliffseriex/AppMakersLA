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


data "aws_vpc" "vpc-ue1" {
  filter {
    name   = "tag:Name"
    values = ["vpc-ue1-mf"]
  }
}

data "aws_secretsmanager_secret_version" "my_secret_version" {
  secret_id = "db_password"  
}

module "lambda" {
  source              = "../../../modules/lambda"
  function_name       = "tasks-lambda-staging"
  handler             = "handler.lambda_handler"
  lambda_zip          = "./artifacts/placeholder.zip"
  memory_size         = 256
  timeout             = 15
  environment_variables = {
    DB_HOST     = "appmakers.cnwwewoekns0.us-east-1.rds.amazonaws.com:5432"
    DB_NAME     = "appmakers"
    DB_USER     = "appmakers"
    DB_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.my_secret_version.secret_string)["db_password"]
  }
}

module "api_gateway" {
  source      = "../../../modules/api_gateway"
  api_name    = "tasks-api-staging"
  lambda_arn  = module.lambda.lambda_arn
  stage_name  = "staging"
}