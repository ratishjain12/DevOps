#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive

# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y

# Install Docker
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker
usermod -aG docker ubuntu

# Wait for EBS volume to be attached (t3.large uses NVMe)
sleep 30

# Format and mount the EBS volume for Elasticsearch
# For t3.large (Nitro-based), the device will be /dev/nvme1n1
if [ -b /dev/nvme1n1 ]; then
  echo "Formatting EBS volume..."
  sudo mkfs.ext4 /dev/nvme1n1
  
  echo "Creating mount point..."
  sudo mkdir -p /opt/elasticsearch-data
  
  echo "Mounting EBS volume..."
  sudo mount /dev/nvme1n1 /opt/elasticsearch-data
  
  echo "Adding to fstab for persistent mounting..."
  echo '/dev/nvme1n1 /opt/elasticsearch-data ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab
  
  echo "Setting permissions..."
  sudo chown -R ubuntu:ubuntu /opt/elasticsearch-data
else
  echo "EBS volume not found at /dev/nvme1n1"
fi

# Create application directory
mkdir -p /opt/nodejs-elk-app
chown -R ubuntu:ubuntu /opt/nodejs-elk-app