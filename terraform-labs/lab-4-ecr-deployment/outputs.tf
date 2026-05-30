output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.lab4.repository_url
}

output "repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.lab4.arn
}

output "registry_id" {
  description = "AWS account ID (registry ID)"
  value       = data.aws_caller_identity.current.account_id
}

output "ecr_login_command" {
  description = "Command to login to ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.lab4.repository_url}"
  sensitive   = true
}

output "push_command" {
  description = "Example command to push an image"
  value       = "docker tag lab2-app:latest ${aws_ecr_repository.lab4.repository_url}:latest && docker push ${aws_ecr_repository.lab4.repository_url}:latest"
}
