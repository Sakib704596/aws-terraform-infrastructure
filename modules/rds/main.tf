# Fetch secret from AWS Secrets Manager
data "aws_secretsmanager_secret" "db_secret" {
  name = "aws-terraform/database"
}

data "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id = data.aws_secretsmanager_secret.db_secret.id
}

# Parse the secret JSON
locals {
  db_credentials = jsondecode(
    data.aws_secretsmanager_secret_version.db_secret_version.secret_string
  )
}

# Security Group for RDS
# Only allows EC2 to connect
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  # Only allow MySQL from EC2 security group
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.ec2_security_group_id]
    description     = "MySQL from EC2 only"
  }

  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-rds-sg"
    Environment = var.environment
  }
}

# Subnet Group for RDS
# Tells RDS which subnets to use
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for RDS"

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "database" {
  identifier        = "${var.project_name}-${var.environment}-db"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.instance_class
  allocated_storage = var.allocated_storage

  db_name  = var.db_name

  # Credentials from AWS Secrets Manager!
  # Never hardcoded! ✅
  username = local.db_credentials["username"]
  password = local.db_credentials["password"]

  # Network config
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Make it private
  publicly_accessible = false

  # Backup config
  backup_retention_period = 0
  skip_final_snapshot     = true

  # Storage encryption
  #storage_encrypted = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-db"
    Environment = var.environment
  }
}