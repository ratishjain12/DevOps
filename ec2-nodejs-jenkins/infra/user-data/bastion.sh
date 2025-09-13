#!/bin/bash

# Update system
sudo apt update -y
sudo apt upgrade -y

# Install required packages
sudo apt install -y git curl wget

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install jq
sudo apt install -y jq

# Create .ssh directory
mkdir -p /home/ubuntu/.ssh
chown ubuntu:ubuntu /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh

