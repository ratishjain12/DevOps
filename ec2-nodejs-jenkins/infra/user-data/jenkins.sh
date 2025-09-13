#!/bin/bash

exec > >(tee /var/log/user-data.log) 2>&1
set -e  # Exit on any error
set -x  # Debug mode

echo "Starting Jenkins setup at $(date)"

export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin

# Update system
apt update -y
apt upgrade -y

# Install basic utilities
apt install -y curl wget git unzip software-properties-common

# Install OpenJDK 17
apt install -y openjdk-17-jdk

# Verify Java installation
java -version
which java

# Set JAVA_HOME
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> /etc/environment
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> /etc/environment

# Install Jenkins
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | apt-key add -
echo "deb https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list
apt update -y
apt install -y jenkins

# Configure Jenkins
tee /etc/default/jenkins << 'EOF'
# defaults for Jenkins automation server
NAME=jenkins

# arguments to pass to java
JAVA_ARGS="-Djava.awt.headless=true -Xmx2g -Xms1g"

PIDFILE=/var/run/$NAME/$NAME.pid

# user and group to be invoked as (default to jenkins)
JENKINS_USER=$NAME
JENKINS_GROUP=$NAME

# location of the jenkins war file
JENKINS_WAR=/usr/share/java/$NAME.war

# jenkins home location
JENKINS_HOME=/var/lib/$NAME

# set this to false if you don't want Jenkins to run by itself
RUN_STANDALONE=true

# log location
JENKINS_LOG=/var/log/$NAME/$NAME.log

# Whether to enable web access logging or not
JENKINS_ENABLE_ACCESS_LOG="no"

# OS LIMITS SETUP
MAXOPENFILES=8192

# port for HTTP connector (default 8080; disable with -1)
HTTP_PORT=8080

# servlet context, important if you want to use apache proxying
PREFIX=/$NAME

# arguments to pass to jenkins
JENKINS_ARGS="--webroot=/var/cache/$NAME/war --httpPort=$HTTP_PORT"

# Set JAVA_HOME for Jenkins
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
EOF

# Start Jenkins
systemctl enable jenkins
systemctl start jenkins

# Wait for Jenkins to start
sleep 10

# Check Jenkins status
systemctl status jenkins

# Install Docker
apt install -y docker.io
systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu
usermod -aG docker jenkins

# Get Jenkins initial password
echo "Jenkins setup completed!"
echo "Initial password:"
cat /var/lib/jenkins/secrets/initialAdminPassword

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
echo "Jenkins URL: http://${PUBLIC_IP}:8080"

echo "Jenkins setup completed successfully at $(date)"