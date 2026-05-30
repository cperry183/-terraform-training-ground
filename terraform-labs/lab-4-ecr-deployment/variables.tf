variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "repository_name" {
  description = "ECR repository name"
  type        = string
  default     = "lab4-app"

  validation {
    condition     = length(var.repository_name) > 0
    error_message = "Repository name cannot be empty."
  }
}
