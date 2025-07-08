variable "name" {
  type        = string
  description = "Name for the ECR repo"
}

variable "ecs_cluster_id" {
  type        = string
  description = "The ECS cluster ID where the app should run"
}

variable "ecs_task_execution_role_arn" {
  type        = string
  description = "The IAM role ARN to use for the ECS task definition"
}

variable "lb_target_group_arn" {
  type        = string
  description = "The LB target group ARN to use for the ECS service"
}

variable "db_host" {
  type        = string
  description = "The hostname of the database to connect to"
}

variable "db_name" {
  type        = string
  description = "The database name"
}

variable "db_user" {
  type        = string
  description = "The database username"
}

variable "db_password" {
  type        = string
  description = "The database password"
}