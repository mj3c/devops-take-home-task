output "target_groups" {
  value = aws_lb_target_group.this
}

output "sg_id" {
  value = aws_security_group.alb.id
}