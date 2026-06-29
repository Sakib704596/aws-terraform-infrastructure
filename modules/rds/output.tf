output "db_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.database.endpoint
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.database.db_name
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.database.port
}

output "rds_security_group_id" {
  description = "RDS security group ID"
  value       = aws_security_group.rds_sg.id
}