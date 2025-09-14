terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.13.0"
    }
  }
}


provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "nodejs-elk-logging-stack-vpc"
  cidr = "10.0.0.0/16"

  azs = ["ap-south-1a"]
  public_subnets = ["10.0.10.0/24"]

  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support = true

  manage_default_security_group = true

  tags = {
    Name = "nodejs-elk-logging-stack-vpc"
    Environment = "production"
    Project = "nodejs-elk-logging-stack"
  }

  public_subnet_tags = {
    Name = "nodejs-elk-logging-stack-public-subnet"
  }
}

resource "aws_security_group" "app_sg" {
  name_prefix = "app-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.node_app_port  
    to_port = var.node_app_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.elastic_search_port
    to_port = var.elastic_search_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.logstash_port
    to_port = var.logstash_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = var.kibana_port
    to_port = var.kibana_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}

resource "aws_key_pair" "main" {
  key_name = "main-key"
  public_key = file("${path.module}/keys/id_rsa.pub")
}


resource "aws_instance" "app_server" {
  ami = "ami-02d26659fd82cf299"
  instance_type = var.instance_type
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  key_name = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data = file("${path.module}/user-data/app.sh")

  tags = {
    Name = "app-server"
  }
}
