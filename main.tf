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