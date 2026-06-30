terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    } 
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  env = terraform.workspace

  config = {
    default = {
      instance_count = 1
      instance_type  = "t3.micro"
      db_class       = "db.t3.micro"
    }
    dev = {
      instance_count = 1
      instance_type  = "t3.micro"
      db_class       = "db.t3.micro"
    }
    prod = {
      instance_count = 2
      instance_type  = "t3.micro"
      db_class       = "db.t3.micro"
    }
  }

  current = local.config[local.env]
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  environment  = var.environment
  project_name = var.project_name
}

# EC2 Module
module "ec2" {
  source = "./modules/ec2"

  environment       = var.environment
  project_name      = var.project_name
  instance_type     = local.current.instance_type
  instance_count    = local.current.instance_count
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  key_name          = aws_key_pair.web_key.key_name
 # private_key_path  = "${path.root}/aws-terraform-key"
}

# RDS Module
module "rds" {
  source = "./modules/rds"

  environment           = var.environment
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ec2_security_group_id = module.ec2.security_group_id
  db_name               = "appdb"
  instance_class        = local.current.db_class
}
# ALB Module
module "alb" {
  source = "./modules/alb"

  environment           = var.environment
  project_name          = var.project_name
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  ec2_instance_ids      = module.ec2.instance_ids
  ec2_security_group_id = module.ec2.security_group_id
}
# SSH Key Pair
resource "aws_key_pair" "web_key" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = file("${path.module}/aws-terraform-key.pub")
}