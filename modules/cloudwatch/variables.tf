variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "ec2_instance_ids" {
  description = "EC2 instance IDs to monitor"
  type        = list(string)
}

variable "rds_instance_id" {
  description = "RDS instance ID to monitor"
  type        = string
}

variable "alb_arn_suffix" {
  description = "ALB ARN suffix for monitoring"
  type        = string
}

variable "alert_email" {
  description = "Email to send alerts to"
  type        = string
}

variable "cpu_threshold" {
  description = "CPU threshold percentage for alarm"
  type        = number
  default     = 80
}