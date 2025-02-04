data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_security_group" "lambda_sg" {
  filter {
    name   = "group-name"
    values = ["lambda-sg"]  
  }
}


output "api_gateway_arn" {
  description = "Full ARN for the API Gateway"
  value       = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.api.id}/*"
}

output "api_endpoint" {
  value = aws_apigatewayv2_api.api.api_endpoint
}

resource "aws_apigatewayv2_api" "api" {
  name          = var.api_name
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "post_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "POST /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_route" "get_route" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /tasks"
  target    = "integrations/${aws_apigatewayv2_integration.integration.id}"
}

resource "aws_apigatewayv2_integration" "integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "HTTP_PROXY"
  integration_uri  = var.alb_listener_arn 
  connection_type   = "VPC_LINK" 
  connection_id     = aws_apigatewayv2_vpc_link.lambda_vpc_link.id
  integration_method = "ANY"
}

resource "aws_apigatewayv2_stage" "stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = var.stage_name
  auto_deploy = true
}

# Deploy API Gateway
resource "aws_apigatewayv2_deployment" "tasks_api_deployment" {  
  api_id = aws_apigatewayv2_api.api.id

  depends_on = [
    aws_apigatewayv2_route.post_route,
    aws_apigatewayv2_route.get_route
  ]
}

resource "aws_apigatewayv2_vpc_link" "lambda_vpc_link" {
  name               = "lambda-vpc-link"
  security_group_ids = [data.aws_security_group.lambda_sg.id]
  subnet_ids         = var.private_subnet_ids
}


