data "aws_s3_object" "lambda_app_zip" {
  bucket = var.s3_bucket
  key    = var.lambda_zip
}

data "aws_s3_object" "lambda_db_migration_zip" {
  bucket = var.s3_bucket
  key    = var.db_migration_zip
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}


# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "lambda.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}
/*
resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
*/
resource "aws_iam_role_policy_attachment" "lambda_exec_policy_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}


# IAM Policy for Lambda Execution
resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "${var.function_name}-policy"
  description = "IAM policy for Lambda execution"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "rds-db:connect"
        ],
        Resource = "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:db:appmakers"
      },
      {
        Effect   = "Allow",
        Action   = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AttachNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.function_name}-role"
      }
    ]
  })
}




# Database Migration Lambda (Runs First)
resource "aws_lambda_function" "db_migration_lambda" {
  function_name = "db-migration"
  runtime       = var.runtime
  role          = aws_iam_role.lambda_exec.arn
  handler       = "db_migration.lambda_handler"

  s3_bucket        = var.s3_bucket
  s3_key           = var.db_migration_zip
  source_code_hash = data.aws_s3_object.lambda_db_migration_zip.etag

  environment {
    variables = var.environment_variables
  }

  memory_size = 128
  timeout     = 10

    # Attach psycopg2 Layer
  layers = [aws_lambda_layer_version.psycopg2_layer.arn]
}


# Ensure Database Migration Runs Before Deploying App Lambda
resource "null_resource" "invoke_db_migration" {
  provisioner "local-exec" {
    command = <<EOT
      aws lambda invoke \
        --function-name ${aws_lambda_function.db_migration_lambda.function_name} \
        --region us-east-1 \
        response.json
    EOT
  }

  depends_on = [aws_lambda_function.db_migration_lambda]
}


# Application Lambda (Depends on DB Migration)
resource "aws_lambda_function" "app_lambda" {
  function_name = var.function_name
  runtime       = var.runtime
  role          = aws_iam_role.lambda_exec.arn
  handler       = var.handler

  s3_bucket        = var.s3_bucket
  s3_key           = var.lambda_zip
  source_code_hash = data.aws_s3_object.lambda_app_zip.etag 

  environment {
    variables = var.environment_variables
  }

  memory_size = var.memory_size
  timeout     = var.timeout

    # Attach Lambda to the VPC
  vpc_config {
    subnet_ids         = var.private_subnet_ids  
    security_group_ids = [var.lambda_security_group_id]  
  }
}

# Ensure App Lambda Deploys Only After DB Migration Completes
resource "null_resource" "deploy_app_lambda" {
  depends_on = [null_resource.invoke_db_migration, aws_lambda_function.app_lambda]
}

# Allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigateway_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.app_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = var.api_gateway_arn
}


resource "aws_lambda_layer_version" "psycopg2_layer" {
  layer_name          = "psycopg2-layer"
  compatible_runtimes = ["python3.8", "python3.9"] 
  filename              = "psycopg2-layer.zip"


}
