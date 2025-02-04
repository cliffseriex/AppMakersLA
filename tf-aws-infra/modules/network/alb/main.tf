resource "aws_lb" "lambda_alb" {
  name               = var.alb_name
  internal           = true  # ✅ Internal ALB for private subnets
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.private_subnet_ids
}

resource "aws_lb_target_group" "lambda_tg" {
  name     = var.target_group_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "lambda"
}

resource "aws_lb_listener" "lambda_listener" {
  load_balancer_arn = aws_lb.lambda_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lambda_tg.arn
  }
}

output "alb_listener_arn" {
  value = aws_lb_listener.lambda_listener.arn
}
