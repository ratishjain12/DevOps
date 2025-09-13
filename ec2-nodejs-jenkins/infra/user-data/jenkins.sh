#!/bin/bash
# ==============================
# EC2 User Data Script for Jenkins + Docker
# ==============================

# Update system
yum update -y

# ------------------------------
# Install Java JDK 11 (required for Jenkins)
# ------------------------------
amazon-linux-extras enable corretto11
yum install -y java-11-amazon-corretto

# Verify Java
java -version

# ------------------------------
# Install Jenkins
# ------------------------------
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install -y jenkins

# ------------------------------
# Install and Configure Docker
# ------------------------------
yum install -y docker
systemctl enable docker
systemctl start docker

# Add users to docker group
usermod -aG docker ec2-user
usermod -aG docker jenkins

# ------------------------------
# Enable and Start Jenkins
# ------------------------------
systemctl enable jenkins
systemctl start jenkins

# ------------------------------
# Expose Jenkins initial password
# ------------------------------
echo "Jenkins initial admin password:" >> /var/log/jenkins.setup.log
cat /var/lib/jenkins/secrets/initialAdminPassword >> /var/log/jenkins.setup.log
chmod 644 /var/log/jenkins.setup.log
