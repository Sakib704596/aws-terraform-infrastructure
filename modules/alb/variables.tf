variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs"
  type        = list(string)
}

variable "ec2_instance_ids" {
  description = "EC2 instance IDs"
  type        = list(string)
}

variable "ec2_security_group_id" {
  description = "EC2 security group ID"
  type        = string
}