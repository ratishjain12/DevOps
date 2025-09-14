output "ec2_public_ip" {
  description = "Public IP of EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "ec2_private_ip" {
  description = "Private IP of EC2 instance"
  value       = aws_instance.app_server.private_ip
}