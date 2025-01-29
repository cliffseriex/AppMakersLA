
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.db_name}-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.50.0.0/16"] # Allow traffic from the VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"      = "RDS PG security group",
    "env"       = "stag",
    "terraform" = "true"
  }
}

resource "aws_db_instance" "rds" {
  identifier              = var.db_identifier
  allocated_storage       = var.allocated_storage
  max_allocated_storage   = var.max_allocated_storage
  engine                  = "postgres"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  username                = var.username
  password                = var.password
  db_name                 = var.db_name
  multi_az                = var.multi_az
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  storage_encrypted       = true
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  monitoring_interval     = var.monitoring_interval
  monitoring_role_arn     = var.monitoring_role_arn

  tags = var.tags
}



output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "rds_port" {
  value = aws_db_instance.rds.port
}

output "rds_id" {
  value = aws_db_instance.rds.id
}
