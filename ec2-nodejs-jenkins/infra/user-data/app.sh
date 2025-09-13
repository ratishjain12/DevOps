#!/bin/bash
# ==============================
# Simple App Server Setup Script (Ubuntu 22.04)
# ==============================
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
# Update system
apt update -y
apt upgrade -y

# Install basic utilities
apt install -y curl wget git

# Install Docker
apt install -y docker.io
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

echo "App server setup completed!"