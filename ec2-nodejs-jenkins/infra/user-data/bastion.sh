#!/bin/bash
# ==============================
# Simple Bastion Setup Script (Ubuntu 22.04)
# ==============================

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin
# Update system
apt update -y
apt upgrade -y

# Install basic utilities
apt install -y curl wget git

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

echo "Bastion setup completed!"