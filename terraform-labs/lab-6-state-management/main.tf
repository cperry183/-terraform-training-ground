# Lab 6: Terraform State Management
# STUB: Configure your remote backend

terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure backend below - see backend.tf.example
# This allows team access to shared state

provider "aws" {
  region = var.aws_region
}

# TODO: Configure S3 backend
# TODO: Setup DynamoDB for state locking
# See README.md for detailed setup
