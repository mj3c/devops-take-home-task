output "id" {
  description = "The ECS cluster ID"
  value       = aws_ecs_cluster.ecs_cluster.id
}

output "ecs_task_execution_role_arn" {
  description = "The IAM Role ARN to use for ECS tasks"
  value       = aws_iam_role.ecs_task.arn
}

output "sg_id" {
  description = "The ID of the security group that ECS instances use"
  value       = aws_security_group.ecs_instance.id
}