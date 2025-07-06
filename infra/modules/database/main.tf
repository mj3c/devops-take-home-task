resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "Allow MySQL access on port 3306"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL access from within VPC"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = var.allow_ingress_from_sgs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "main" {
  identifier        = var.name
  db_name           = replace("${var.name}-db", "-", "")
  engine            = "mysql"
  allocated_storage = var.allocated_storage
  engine_version    = var.mysql_version
  instance_class    = var.instance_class
  username          = replace(var.username, "-", "")
  password          = var.password

  db_subnet_group_name   = var.subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot = true
}