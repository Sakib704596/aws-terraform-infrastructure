variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-terraform"
}
variable "ssh_public_key" {
  description = "SSH public key content"
  type        = string
}
variable "alert_email" {
  description = "Email for CloudWatch alerts"
  type        = string
  default     = "khsakib2005@gmail.com"
}