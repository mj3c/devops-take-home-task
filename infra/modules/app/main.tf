data "aws_region" "current" {}

resource "aws_ecs_task_definition" "app" {
  family             = var.name
  execution_role_arn = var.ecs_task_execution_role_arn
  network_mode       = "bridge"
  container_definitions = jsonencode([
    {
      name      = var.name
      image     = "wordpress:latest"
      memory    = 128
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "WORDPRESS_DB_HOST"
          value = var.db_host
        },
        {
          name  = "WORDPRESS_DB_USER"
          value = var.db_user
        },
        {
          name  = "WORDPRESS_DB_NAME"
          value = var.db_name
        },
      ]
      secrets = [
        {
          name      = "WORDPRESS_DB_PASSWORD"
          valueFrom = aws_ssm_parameter.db_password.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/${var.name}"
          awslogs-region        = data.aws_region.current.region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
  ])
}

resource "aws_ecs_service" "app" {
  name            = var.name
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = var.name
    container_port   = 80
  }

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${var.name}"
  retention_in_days = 7
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.name}/db_password"
  value = var.db_password
  type  = "SecureString"
}