output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "web_server_ips" {
  description = "Web server public IPs"
  value       = module.ec2.public_ips
}

output "web_server_urls" {
  description = "Web server URLs"
  value       = [for ip in module.ec2.public_ips : "http://${ip}"]
}

output "db_endpoint" {
  description = "Database endpoint"
  value       = module.rds.db_endpoint
}

output "db_name" {
  description = "Database name"
  value       = module.rds.db_name
}
output "alb_dns_name" {
  description = "ALB DNS name - use this to access app!"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "ALB URL"
  value       = "http://${module.alb.alb_dns_name}"
}

output "cloudwatch_dashboard_url" {
  description = "CloudWatch dashboard URL"
  value       = module.cloudwatch.dashboard_url
}

output "sns_topic_arn" {
  description = "SNS alerts topic ARN"
  value       = module.cloudwatch.sns_topic_arn
}