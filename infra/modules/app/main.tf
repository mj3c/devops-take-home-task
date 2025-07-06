resource "aws_ecr_repository" "app" {
  name = var.name
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_task_definition" "app" {
  family             = var.name
  execution_role_arn = var.ecs_task_execution_role_arn
  network_mode       = "bridge"
  container_definitions = jsonencode([
    {
      name      = var.name
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 0
          protocol      = "tcp"
        }
      ]
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
