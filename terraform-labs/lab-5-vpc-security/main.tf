# Lab 5: VPC & Security - Production Networking
# STUB: Add your VPC configuration here

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project = "terraform-labs"
      Lab     = "lab-5"
    }
  }
}

# TODO: Add VPC, subnets, routing, security groups
# See README.md for architecture
