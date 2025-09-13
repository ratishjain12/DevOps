
# Keep the existing key pair
resource "aws_key_pair" "main" {
  key_name   = "main-key"
  public_key = file("${path.module}/keys/id_rsa.pub") 
}

# Keep existing ALB configuration
resource "aws_lb" "app_alb" {
  name               = "app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false

  tags = {
    Name = "app-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "app-tg"
  }
}

resource "aws_lb_target_group_attachment" "app_tg_attachment" {
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app_server.id
  port             = 3000
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Updated instances with Ubuntu
resource "aws_instance" "bastion" {
  ami                         = "ami-02d26659fd82cf299"
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  subnet_id                   = module.vpc.public_subnets[0]
  user_data                   = file("${path.module}/user-data/bastion.sh")


  tags = {
    Name = "bastion-server"
  }
}

resource "aws_instance" "jenkins_server" {
  ami                         = "ami-02d26659fd82cf299"
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.main.key_name
  associate_public_ip_address = true
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  user_data                   = file("${path.module}/user-data/jenkins.sh")

  tags = {
    Name = "jenkins-server"
  }
}

resource "aws_instance" "app_server" {
  ami                    = "ami-02d26659fd82cf299"
  instance_type          = var.instance_type
  key_name              = aws_key_pair.main.key_name
  subnet_id             = module.vpc.private_subnets[0]
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data             = file("${path.module}/user-data/app.sh")

  tags = {
    Name = "app-server"
  }
}