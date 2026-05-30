# Lab 4: ECR & Docker Image Registry
# Build, push, and manage Docker images with AWS ECR

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
      Lab         = "lab-4"
    }
  }
}

# ECR Repository
resource "aws_ecr_repository" "lab4" {
  name                 = var.repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = "lab4-ecr-repo"
  }
}

# ECR Repository Policy (allow pull from specific AWS account)
resource "aws_ecr_repository_policy" "lab4" {
  repository = aws_ecr_repository.lab4.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

# ECR Lifecycle Policy (clean up old images)
resource "aws_ecr_lifecycle_policy" "lab4" {
  repository = aws_ecr_repository.lab4.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images after 7 days"
        selection = {
          tagStatus     = "untagged"
          countType     = "sinceImagePushed"
          countUnit     = "days"
          countNumber   = 7
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Output ECR login command
resource "null_resource" "ecr_login_command" {
  provisioners "local-exec" {
    command = "echo 'Login to ECR with: aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.lab4.repository_url}'"
  }

  depends_on = [aws_ecr_repository.lab4]
}
