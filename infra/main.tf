module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs              = var.vpc_azs
  private_subnets  = var.vpc_private_subnets
  public_subnets   = var.vpc_public_subnets
  database_subnets = var.vpc_database_subnets

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "ecs_cluster" {
  source = "./modules/ecs_cluster"

  name          = var.app_name
  instance_type = var.ecs_ec2_instance_type
  vpc_id        = module.vpc.vpc_id
  subnets       = module.vpc.private_subnets
}

module "database" {
  source = "./modules/database"

  name              = var.app_name
  instance_class    = var.rds_instance_class
  mysql_version     = var.rds_mysql_version
  allocated_storage = var.rds_allocated_storage
  username          = var.app_name
  vpc_id            = module.vpc.vpc_id
  subnet_group_name = module.vpc.database_subnet_group_name
}