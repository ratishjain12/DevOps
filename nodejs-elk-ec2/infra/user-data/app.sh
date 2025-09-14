#!/bin/bash
# Update system
apt update && apt upgrade -y

# Install Git
apt install -y git

# Install Docker
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -y docker-ce docker-ce-cli containerd.io

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Configure system limits for Elasticsearch
echo "vm.max_map_count=262144" | tee -a /etc/sysctl.conf
sysctl -p

# Create application directory
mkdir -p /opt/nodejs-elk-app
chown -R ubuntu:ubuntu /opt/nodejs-elk-app
