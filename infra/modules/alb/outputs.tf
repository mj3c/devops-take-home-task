output "target_groups" {
  value = aws_lb_target_group.this
}

output "sg_id" {
  value = aws_security_group.alb.id
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}