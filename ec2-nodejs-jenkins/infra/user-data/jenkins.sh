#!/bin/bash

# Update system
sudo apt update -y
sudo apt upgrade -y

# Install Java JDK 11 (required for Jenkins)
sudo apt install -y openjdk-11-jdk

# Set JAVA_HOME environment variable
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> /home/ubuntu/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /home/ubuntu/.bashrc

# Install Jenkins repository
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update

# Install Jenkins
sudo apt install -y jenkins

# Start and enable Jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Add jenkins user to docker group
sudo usermod -a -G docker jenkins

# Install Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ubuntu

# Get Jenkins initial admin password
JENKINS_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

# Create info file
cat > /home/ubuntu/jenkins-info.txt << EOF
Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):8080
Initial Admin Password: $JENKINS_PASSWORD
EOF