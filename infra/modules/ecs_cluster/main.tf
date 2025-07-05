data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

resource "aws_security_group" "ecs_instance" {
  name        = "${var.name}-instance"
  vpc_id      = var.vpc_id
  description = "The main SG for the ECS instances that will allow traffic to ports 80/443"

  dynamic "ingress" {
    for_each = var.allow_ingress_from_sgs
    content {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = ingress.value
    }
  }

  dynamic "ingress" {
    for_each = var.allow_ingress_from_sgs
    content {
      from_port       = 443
      to_port         = 443
      protocol        = "tcp"
      security_groups = ingress.value
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "ecs_lt" {
  name_prefix   = var.name
  image_id      = data.aws_ami.ecs_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.ecs_instance.id]

  iam_instance_profile {
    name = "AmazonEC2ContainerServiceforEC2Role"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.ebs_volume_size
      volume_type = "gp3"
    }
  }

  user_data = base64encode((templatefile("${path.module}/templates/ecs.sh.tpl", {
    cluster_name = var.name
  })))
}

resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = var.subnets
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.name
}