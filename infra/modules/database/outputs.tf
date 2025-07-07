output "rds_address" {
  value = aws_db_instance.main.address
}

output "rds_mysql_user" {
  value = aws_db_instance.main.username
}

output "rds_db_name" {
  value = aws_db_instance.main.db_name
}