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

variable "container_image" {
  description = "Docker image URL (use public image or ECR)"
  type        = string
  default     = "httpbin.org/image/png" # Replace with your image

  validation {
    condition     = length(var.container_image) > 0
    error_message = "Container image must be specified."
  }
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 5000

  validation {
    condition     = var.container_port > 0 && var.container_port < 65536
    error_message = "Container port must be between 1 and 65535."
  }
}

variable "task_cpu" {
  description = "ECS task CPU (256, 512, 1024, 2048, 4096)"
  type        = string
  default     = "256"

  validation {
    condition     = contains(["256", "512", "1024", "2048", "4096"], var.task_cpu)
    error_message = "Task CPU must be one of: 256, 512, 1024, 2048, 4096."
  }
}

variable "task_memory" {
  description = "ECS task memory (512, 1024, 2048, ...)"
  type        = string
  default     = "512"

  validation {
    condition     = tonumber(var.task_memory) >= 512
    error_message = "Task memory must be at least 512."
  }
}

variable "app_version" {
  description = "Application version"
  type        = string
  default     = "1.0.0"
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2

  validation {
    condition     = var.desired_count > 0
    error_message = "Desired count must be greater than 0."
  }
}

variable "max_capacity" {
  description = "Maximum number of tasks for auto-scaling"
  type        = number
  default     = 4

  validation {
    condition     = var.max_capacity > 0
    error_message = "Max capacity must be greater than 0."
  }
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.log_retention_days)
    error_message = "Log retention must be a valid CloudWatch value."
  }
}
