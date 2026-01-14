variable "aws_profile" {
  description = "AWS profile to use"
  type        = string
  default     = "galiceau-labs"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "db-access-test"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b"]
}

variable "ssh_public_key" {
  description = "SSH public key for EC2 instances"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "testdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

