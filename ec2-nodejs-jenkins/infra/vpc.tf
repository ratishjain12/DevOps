module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "project-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["ap-south-1a", "ap-south-1b"]
  private_subnets = ["10.0.10.0/24", "10.0.20.0/24"]  # Private subnets
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]    # Public subnets

  enable_nat_gateway = true
  single_nat_gateway = true
  enable_vpn_gateway = false

  # Additional configuration for production
  enable_dns_hostnames = true
  enable_dns_support   = true

  manage_default_security_group = true
  # Tags
  tags = {
    Name        = "project-vpc"
    Environment = "production"
    Project     = "ec2-nodejs-jenkins"
  }

  # Subnet tags
  public_subnet_tags = {
    Type = "Public"
    Name = "public-subnet"
  }

  private_subnet_tags = {
    Type = "Private"
    Name = "private-subnet"
  }
}