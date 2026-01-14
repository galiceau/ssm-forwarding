# Data source pour récupérer la dernière AMI Amazon Linux 2023
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair pour SSH (à créer manuellement ou via AWS CLI)
# aws ec2 create-key-pair --key-name db-access-test-key --query 'KeyMaterial' --output text > db-access-test-key.pem
resource "aws_key_pair" "main" {
  key_name   = "${var.project_name}-key"
  public_key = var.ssh_public_key

  tags = {
    Name = "${var.project_name}-key"
  }
}

# EC2 Instance dans le subnet App (privé)
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_app.id
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = aws_key_pair.main.key_name
  iam_instance_profile   = aws_iam_instance_profile.ssm_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y mysql postgresql15
              echo "App server ready" > /home/ec2-user/status.txt
              EOF

  tags = {
    Name = "${var.project_name}-app-server"
    Type = "Application"
  }
}

# Security Group pour l'instance App
resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for app server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "SSH from bastion"
    from_port       = 22
    to_port         = 22
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
    Name = "${var.project_name}-app-sg"
  }
}

# Mise à jour du Security Group Database pour accepter les connexions depuis App
resource "aws_security_group_rule" "db_from_app" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.app.id
  security_group_id        = aws_security_group.database.id
  description              = "MySQL from app server"
}
