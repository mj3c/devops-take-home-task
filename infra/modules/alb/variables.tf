variable "name" {
  type        = string
  description = "The ALB name, also interpolated into related resource names"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to use for the ALB"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs to launch the ALB in"
}

variable "targets" {
  type = map(object({
    name         = string
    port         = number
    priority     = number
    path_pattern = string
  }))
  description = "List of targets for the ALB"
}