output "app_url" {
  description = "The URL to access the demo-app"
  value       = module.alb.alb_dns_name
}