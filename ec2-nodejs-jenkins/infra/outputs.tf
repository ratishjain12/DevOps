output "bastion_public_ip" {
  description = "Public IP of Bastion host"
  value       = aws_instance.bastion.public_ip
}

output "jenkins_public_ip" {
  description = "Private IP of Jenkins server"
  value       = aws_instance.jenkins_server.public_ip
}

output "app_private_ip" {
  description = "Private IP of App server"
  value       = aws_instance.app_server.private_ip
}
