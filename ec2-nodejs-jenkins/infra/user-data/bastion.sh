# Update infra/user-data/bastion.sh
#!/bin/bash
sudo yum update -y

# Install required packages
sudo yum install -y git curl wget

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Install jq
sudo yum install -y jq

# Install nginx
sudo yum install -y nginx

# Create .ssh directory
mkdir -p /home/ec2-user/.ssh
chown ec2-user:ec2-user /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh

