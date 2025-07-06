resource "aws_security_group" "alb" {
  name        = "${var.name}-alb"
  vpc_id      = var.vpc_id
  description = "The main ALB SG that takes any traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "main" {
  name               = var.name
  load_balancer_type = "application"
  subnets            = var.subnets
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.https_self_signed.arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not found"
      status_code  = "404"
    }
  }
}

resource "aws_acm_certificate" "https_self_signed" {
  private_key      = file("${path.module}/certs/selfsigned.key")
  certificate_body = file("${path.module}/certs/selfsigned.crt")
}

resource "aws_lb_target_group" "this" {
  for_each = var.targets
  name     = each.value.name
  port     = each.value.port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }

  target_type = "instance"
}

resource "aws_lb_listener_rule" "this" {
  for_each     = var.targets
  listener_arn = aws_lb_listener.https.arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.key].arn
  }

  condition {
    path_pattern {
      values = [each.value.path_pattern]
    }
  }
}
