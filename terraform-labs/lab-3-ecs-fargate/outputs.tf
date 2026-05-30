output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = aws_lb.lab3.dns_name
}

output "alb_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.lab3.dns_name}"
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.lab3.name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.lab3.name
}

output "cloudwatch_log_group" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.ecs.name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.lab3.arn
}

output "task_definition_arn" {
  description = "ARN of the task definition"
  value       = aws_ecs_task_definition.lab3.arn
}
