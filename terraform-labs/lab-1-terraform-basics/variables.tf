variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Instance type should be t3 family."
  }
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string

  validation {
    condition     = length(var.key_name) > 0
    error_message = "Key name cannot be empty. Create an EC2 Key Pair in AWS first."
  }
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.allowed_ssh_cidrs) > 0
    error_message = "At least one CIDR block must be specified."
  }
}
