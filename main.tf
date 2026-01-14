# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Subnet Public (1 subnet)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zones[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet"
    Tier = "Public"
  }
}

# Subnet Privé DB (pour la base de données)
resource "aws_subnet" "private_db" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = var.availability_zones[0]

  tags = {
    Name = "${var.project_name}-private-db-subnet"
    Tier = "Private"
    Type = "Database"
  }
}

# Subnet Privé App (pour les applications)
resource "aws_subnet" "private_app" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = var.availability_zones[1]

  tags = {
    Name = "${var.project_name}-private-app-subnet"
    Tier = "Private"
    Type = "Application"
  }
}

# Elastic IP pour NAT Gateway (optionnel, coûte de l'argent)
# resource "aws_eip" "nat" {
#   domain = "vpc"
#   tags = {
#     Name = "${var.project_name}-nat-eip"
#   }
# }

# NAT Gateway (optionnel, coûte de l'argent - commenté par défaut)
# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = aws_subnet.public.id
#   tags = {
#     Name = "${var.project_name}-nat-gw"
#   }
# }

# Route Table Public
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route Table Private
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  # Route vers NAT Gateway (décommenter si NAT Gateway activé)
  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.main.id
  # }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Association Route Table Public
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Association Route Table Private DB
resource "aws_route_table_association" "private_db" {
  subnet_id      = aws_subnet.private_db.id
  route_table_id = aws_route_table.private.id
}

# Association Route Table Private App
resource "aws_route_table_association" "private_app" {
  subnet_id      = aws_subnet.private_app.id
  route_table_id = aws_route_table.private.id
}

# Security Group pour Bastion/Jump Host (dans subnet public)
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-bastion-sg"
  }
}

# Security Group pour Database (dans subnet privé)
resource "aws_security_group" "database" {
  name        = "${var.project_name}-database-sg"
  description = "Security group for database"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL/Aurora from bastion"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  ingress {
    description     = "PostgreSQL from bastion"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-database-sg"
  }
}

# DB Subnet Group pour RDS (utilise les 2 subnets privés)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = [aws_subnet.private_db.id, aws_subnet.private_app.id]

  tags = {
    Name = "${var.project_name}-db-subnet-group"
  }
}
