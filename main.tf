terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}


provider "aws" {
  region = "eu-west-2"
}


module "vpc" {
    source = "./modules/vpc"
    az1 = var.az1
    az2 = var.az2
  
}

module "security" {
  source = "./modules/security"
  vpc_id = module.vpc.vpc_id
}


module "rds" {
  source = "./modules/rds"
  private_subnet_ids = module.vpc.private_subnets_ids
  rds_sg_id = module.security.rds_sg_id
  db_username = var.db_username
  db_password = var.db_password

}

module "ecs" {
  source = "./modules/ecs"
  database_url = "postgresql://${var.db_username}:${var.db_password}@${module.rds.db_endpoint}/${module.rds.db_name}"
  private_subnet_ids = module.vpc.private_subnets_ids
  ecs_security_group_id = [module.security.ecs_sg_id]
}