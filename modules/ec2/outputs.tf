output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.web[*].id
}

output "public_ips" {
  description = "Public IPs of web servers"
  value       = aws_instance.web[*].public_ip
}

output "security_group_id" {
  description = "EC2 security group ID"
  value       = aws_security_group.ec2_sg.id
}