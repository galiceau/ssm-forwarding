# RDS MySQL Database dans le subnet DB (privé)
resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-db"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.database.id]
  skip_final_snapshot    = true
  publicly_accessible    = false

  # Free tier settings
  backup_retention_period = 0
  multi_az                = false

  tags = {
    Name = "${var.project_name}-mysql-db"
  }
}
