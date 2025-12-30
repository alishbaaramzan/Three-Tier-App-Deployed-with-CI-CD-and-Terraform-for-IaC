terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.26.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group
resource "aws_security_group" "my_sg" {
  name        = "my-security-group"
  description = "Allow SSH, HTTP, App Ports"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair for EC2
resource "aws_key_pair" "instance_key" {
  key_name   = "devops-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# EC2 Instance
resource "aws_instance" "my_ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.instance_key.key_name
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  user_data = file("user_data.sh")

  tags = {
    Name = "my-ec2-instance"
  }

  depends_on = [aws_key_pair.instance_key]
}

# ECR Repositories
resource "aws_ecr_repository" "backend" {
  name = "devops-backend"
}

resource "aws_ecr_repository" "frontend" {
  name = "devops-frontend"
}

