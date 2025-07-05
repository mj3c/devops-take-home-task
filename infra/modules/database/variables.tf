variable "name" {
  type        = string
  description = "The RDS instance name, also interpolated into related resource names"
}

variable "instance_class" {
  type        = string
  description = "The RDS instance class to use"
}

variable "allocated_storage" {
  type        = number
  description = "The allocated storage (in GB) for the RDS instance"
}

variable "mysql_version" {
  type        = string
  description = "The MySQL engine version to use"
}

variable "username" {
  type        = string
  description = "The MySQL username for the master user"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID for the RDS instance's security group"
}

variable "subnet_group_name" {
  type        = string
  description = "The subnet group name for the RDS instance"
}

variable "allow_ingress_from_sgs" {
  type        = list(string)
  description = "List of SG IDs to allow ingress from"
  default     = []
}