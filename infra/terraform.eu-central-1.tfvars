vpc_name             = "main"
vpc_cidr             = "10.0.0.0/16"
vpc_azs              = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
vpc_private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
vpc_public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
vpc_database_subnets = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]

app_name = "my-app"

ecs_ec2_instance_type = "t3.micro"

rds_instance_class    = "db.t3.micro"
rds_mysql_version     = "8.0"
rds_allocated_storage = 10