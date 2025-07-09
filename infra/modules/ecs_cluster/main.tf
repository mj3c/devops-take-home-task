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
  description = "The main SG for the ECS instances that will allow traffic to port 80"

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = var.allow_ingress_from_sgs
  }

  # This is the dynamic port range that ECS uses in bridge networking mode,
  # we need to allow ingress to it so ALB target group health checks would pass
  ingress {
    from_port       = 32768
    to_port         = 60999
    protocol        = "tcp"
    security_groups = var.allow_ingress_from_sgs
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
    name = aws_iam_instance_profile.ecs_for_ec2.name
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
  name                = var.name
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

# This is an equivalent of https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonECSTaskExecutionRolePolicy.html
# With the addition of SSM access and KMS for decryption
data "aws_iam_policy_document" "ecs_task" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "ecs_task" {
  name   = "CustomECSTaskExecutionPolicy"
  policy = data.aws_iam_policy_document.ecs_task.json
}

resource "aws_iam_role" "ecs_task" {
  name               = "CustomECSTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

# This is an equivalent of https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonEC2ContainerServiceforEC2Role.html
data "aws_iam_policy_document" "ecs_for_ec2" {
  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "ec2:DescribeTags",
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:UpdateContainerInstancesState",
      "ecs:Submit*",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }

  statement {
    effect    = "Allow"
    resources = ["*"]
    actions   = ["ecs:TagResource"]

    condition {
      test     = "StringEquals"
      variable = "ecs:CreateAction"

      values = [
        "CreateCluster",
        "RegisterContainerInstance",
      ]
    }
  }
}

data "aws_iam_policy_document" "ecs_for_ec2_trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "ecs_for_ec2" {
  name   = "CustomECSForEC2Policy"
  policy = data.aws_iam_policy_document.ecs_for_ec2.json
}

resource "aws_iam_role" "ecs_for_ec2" {
  name               = "CustomECSForEC2Role"
  assume_role_policy = data.aws_iam_policy_document.ecs_for_ec2_trust.json
}

resource "aws_iam_role_policy_attachment" "ecs_for_ec2" {
  role       = aws_iam_role.ecs_for_ec2.name
  policy_arn = aws_iam_policy.ecs_for_ec2.arn
}

resource "aws_iam_instance_profile" "ecs_for_ec2" {
  name = "CustomECSForEC2InstanceProfile"
  role = aws_iam_role.ecs_for_ec2.name
}