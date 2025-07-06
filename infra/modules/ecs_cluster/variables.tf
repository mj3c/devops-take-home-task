variable "name" {
  type        = string
  description = "The ECS cluster name, also interpolated into related resource names"
}

variable "instance_type" {
  type        = string
  description = "The EC2 instance type for the ECS cluster instances"
}

variable "ebs_volume_size" {
  type        = number
  description = "The EBS volume size (in GB) for the ECS instances"
  default     = 30
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID to use for the ECS cluster"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs to launch instances in"
}