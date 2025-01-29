resource "aws_sns_topic" "alerts" {
  name = "rds-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.sns_email_address
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "RDS-CPU-High"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }
  alarm_actions = [aws_sns_topic.alerts.arn]
}

output "alarm_arn" {
  value = aws_cloudwatch_metric_alarm.cpu_high.arn
}
