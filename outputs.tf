output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = aws_subnet.public.id
}

output "private_db_subnet_id" {
  description = "Private DB subnet ID"
  value       = aws_subnet.private_db.id
}

output "private_app_subnet_id" {
  description = "Private App subnet ID"
  value       = aws_subnet.private_app.id
}

output "bastion_security_group_id" {
  description = "Bastion security group ID"
  value       = aws_security_group.bastion.id
}

output "database_security_group_id" {
  description = "Database security group ID"
  value       = aws_security_group.database.id
}

output "db_subnet_group_name" {
  description = "DB subnet group name"
  value       = aws_db_subnet_group.main.name
}

output "app_instance_id" {
  description = "App EC2 instance ID"
  value       = aws_instance.app.id
}

output "app_instance_private_ip" {
  description = "App EC2 instance private IP"
  value       = aws_instance.app.private_ip
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value       = aws_db_instance.main.endpoint
}

output "rds_address" {
  description = "RDS database address"
  value       = aws_db_instance.main.address
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}


