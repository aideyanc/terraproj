
resource "aws_db_instance" "o4bproject_db" {
  allocated_storage            = var.rds["allocated_storage"]
  max_allocated_storage        = var.rds["max_allocated_storage"]
  engine                       = var.rds["engine"]
  engine_version               = var.rds["engine_version"]
  instance_class               = var.rds["instance_class"]
  name                         = var.rds["db_name"]
  username                     = var.rds["username"]
  password                     = var.rds["password"]
  parameter_group_name         = var.rds["parameter_group_name"]
  skip_final_snapshot          = var.rds["skip_final_snapshot"]
  deletion_protection          = var.rds["deletion_protection"]
  backup_retention_period      = var.rds["backup_retention_period"]
  performance_insights_enabled = var.rds["performance_insights_enabled"]
  copy_tags_to_snapshot        = var.rds["copy_tags_to_snapshot"]
  multi_az                     = var.rds["multi_az"]

  tags = {
    Name        = "AmpDevO4b-rds"
    Environment = "dev"
  }
}

resource "aws_db_subnet_group" "o4bproject_db_subnet_group" {
  name       = "ampdevo4b_db"
  subnet_ids = [aws_subnet.o4bproject-private[0].id, aws_subnet.o4bproject-private[1].id]

  tags = {
    Name = "AmpDevO4b-db-subnet-group"
  }
}
