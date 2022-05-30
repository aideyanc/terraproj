
resource "aws_db_instance" "o4bproject_db" {
  allocated_storage    = var.rds["allocated_storage"]
  max_allocated_storage = var.rds["max_allocated_storage"]
  engine               = var.rds["engine"]
  engine_version       = var.rds["engine_version"]
  instance_class       = var.rds["instance_class"]
  name                 = var.rds["name"]
  username             = var.rds["username"]
  password             = var.rds["password"]
  parameter_group_name = var.rds["parameter_group_name"]
  skip_final_snapshot  = var.rds["skip_final_snapshot "]
  enable_deletion_protection = var.rds["enable_deletion_protection"]
  backup_retention_period = var.rds["backup_retention_period"]
  performance_insights_enabled = var.rds["performance_insights_enabled"]
  copy_tags_to_snapshot = var.rds["copy_tags_to_snapshot"]
  multi_az = var.rds["multi_az"]
  security_group_ids = [aws_security_group.o4bproject_dev_ec2_private_sg.id, aws_security_group.o4bproject_rds_sg.id]

  tags = {
      Name = "o4bproject-rds"
      Environment = "dev"
  }
}

resource "aws_db_subnet_group" "o4bproject_db_subnet_group" {
  name       = "o4bproject_db"
  subnet_ids = [aws_subnet.o4bproject-private.id]

  tags = {
    Name = "o4bproject-db-subnet-group"
  }
}
