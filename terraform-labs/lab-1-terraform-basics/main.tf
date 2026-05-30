# Lab 1: Terraform Basics
# Goal: Create a simple EC2 instance and learn Terraform fundamentals

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
      Environment = var.environment
      Project     = "terraform-labs"
      CreatedBy   = "Terraform"
      Lab         = "lab-1"
    }
  }
}

# Get the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group for our instance
resource "aws_security_group" "lab1" {
  name        = "lab1-sg"
  description = "Security group for Lab 1 EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lab1-security-group"
  }
}

# EC2 Instance
resource "aws_instance" "lab1" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.lab1.id]

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    environment = var.environment
  }))

  tags = {
    Name = "lab1-instance"
  }

  depends_on = [aws_security_group.lab1]
}

# Elastic IP for static public IP
resource "aws_eip" "lab1" {
  instance = aws_instance.lab1.id
  domain   = "vpc"

  tags = {
    Name = "lab1-eip"
  }

  depends_on = [aws_instance.lab1]
}
