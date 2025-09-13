data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "main" {
  key_name   = "main-key"
  public_key = file("${path.module}/keys/id_rsa.pub") 
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type # Smallest instance
  key_name              = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  subnet_id             = module.vpc.public_subnets[0]
  user_data = file("${path.module}/user-data/bastion.sh")
  provisioner "file" {
    source      = "${path.module}/keys/id_rsa"
    destination = "/home/ec2-user/.ssh/id_rsa"
    
    connection {
      type        = "ssh"
      host        = self.public_ip
      user        = "ec2-user"
      private_key = file("${path.module}/keys/id_rsa")
      timeout     = "2m"
    }
  }

  tags = {
    Name = "bastion-server"
  }
}


resource "aws_instance" "jenkins_server" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    subnet_id =  module.vpc.private_subnets[0]
    vpc_security_group_ids = [aws_security_group.jenkins_sg.id]
    user_data = file("${path.module}/user-data/jenkins.sh")
    tags = {
      Name = "jenkins-server"
    }
}

resource "aws_instance " "app_server" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type
    subnet_id = module.vpc.private_subnets[1]
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    user_data = file("${path.module}/user-data/app.sh")
    tags = {
      Name = "app-server"
    }
}