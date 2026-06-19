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