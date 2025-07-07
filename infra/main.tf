module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.env_name
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

  name          = var.env_name
  instance_type = var.ecs_ec2_instance_type
  vpc_id        = module.vpc.vpc_id
  subnets       = module.vpc.private_subnets
}

module "database" {
  source = "./modules/database"

  name                   = var.app_name
  instance_class         = var.rds_instance_class
  mysql_version          = var.rds_mysql_version
  allocated_storage      = var.rds_allocated_storage
  username               = var.app_name
  password               = var.rds_mysql_password
  vpc_id                 = module.vpc.vpc_id
  subnet_group_name      = module.vpc.database_subnet_group_name
  allow_ingress_from_sgs = [module.demo-app.sg_id, module.alb.sg_id]
}

module "alb" {
  source = "./modules/alb"

  name    = var.env_name
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  targets = var.alb_targets
}

module "demo-app" {
  source = "./modules/app"

  name                        = var.app_name
  ecs_cluster_id              = module.ecs_cluster.id
  ecs_task_execution_role_arn = module.ecs_cluster.ecs_task_execution_role_arn
  lb_target_group_arn         = module.alb.target_groups[var.app_name].arn
  subnets                     = module.vpc.private_subnets
  vpc_id                      = module.vpc.vpc_id
  allow_ingress_from_sgs      = [module.alb.sg_id]

  db_host     = module.database.rds_address
  db_name     = module.database.rds_db_name
  db_user     = module.database.rds_mysql_user
  db_password = var.rds_mysql_password
}