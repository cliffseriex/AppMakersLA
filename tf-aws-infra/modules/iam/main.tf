#################### RDS Cloudwatch monitoringn ####################
# Check if the IAM role exists
data "aws_iam_role" "existing_rds_monitoring" {
  name = "rds-monitoring-role"
}

# Create IAM role only if it doesn't exist
resource "aws_iam_role" "rds_monitoring" {
  count = length(data.aws_iam_role.existing_rds_monitoring.id) == 0 ? 1 : 0

  name               = "rds-monitoring-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach policy to the role
resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = length(aws_iam_role.rds_monitoring) > 0 ? aws_iam_role.rds_monitoring[0].name : data.aws_iam_role.existing_rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Output the ARN of the IAM role
output "monitoring_role_arn" {
  description = "The ARN of the IAM role for enhanced RDS monitoring"
  value       = length(aws_iam_role.rds_monitoring) > 0 ? aws_iam_role.rds_monitoring[0].arn : data.aws_iam_role.existing_rds_monitoring.arn
}


# Create IAM policy for Secrets Manager access
resource "aws_iam_policy" "rds_secret_manager_access" {
  name        = "RDSSecretManagerAccess"
  description = "IAM policy to allow RDS monitoring role to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_secret_manager_access_attachment" {
  role       = length(aws_iam_role.rds_monitoring) > 0 ? aws_iam_role.rds_monitoring[0].name : data.aws_iam_role.existing_rds_monitoring.name
  policy_arn = aws_iam_policy.rds_secret_manager_access.arn
}
