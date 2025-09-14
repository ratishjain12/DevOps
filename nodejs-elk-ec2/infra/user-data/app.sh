#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive
# Update system
apt-get update -y

# Install basic utilities
apt install -y curl wget git

# Install Docker
apt install -y docker.io
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

mkdir -p /opt/nodejs-elk-app
chown -R ubuntu:ubuntu /opt/nodejs-elk-app