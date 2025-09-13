**Pipeline Flow:**

1. Code push to GitHub → Webhook triggers Jenkins
2. Jenkins builds Docker image
3. Pushes image to Docker Hub
4. Deploys to App Server via Bastion host

## ✅ Prerequisites

- AWS Account with appropriate permissions
- GitHub repository with your Node.js application
- Docker Hub account
- Terraform installed locally
- SSH key pair generated

## �� Infrastructure Setup

### 1. Deploy Infrastructure

```bash
cd infra/
terraform init
terraform plan
terraform apply
```

### 2. Get Instance Information

After deployment, note the output values:

```bash
terraform output
```

**Important Outputs:**

- `jenkins_public_ip`: Jenkins server public IP
- `bastion_public_ip`: Bastion host public IP
- `app_private_ip`: App server private IP

### 3. Access Jenkins

```bash
# Get Jenkins URL
echo "Jenkins URL: http://$(terraform output -raw jenkins_public_ip):8080"

# Get initial admin password
ssh -i keys/id_rsa ubuntu@$(terraform output -raw jenkins_public_ip) "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
```

## 🔧 Jenkins Initial Setup

### 1. First-Time Setup

1. Open Jenkins URL: `http://JENKINS_IP:8080`
2. Enter the initial admin password
3. Install suggested plugins
4. Create admin user account

### 2. Install Required Plugins

Go to **Manage Jenkins** → **Manage Plugins** → **Available** and install:

- **GitHub Plugin** - GitHub integration
- **GitHub Branch Source Plugin** - Branch management
- **Pipeline Plugin** - Pipeline support
- **Git Plugin** - Git integration
- **Docker Plugin** - Docker support
- **SSH Agent Plugin** - SSH key management
- **Credentials Binding Plugin** - Credential management

### 3. Configure GitHub Integration

1. Go to **Manage Jenkins** → **Configure System**
2. Scroll to **GitHub** section
3. Add GitHub server:
   - **Name**: `GitHub`
   - **API URL**: `https://api.github.com`
   - ✅ Check "Manage hooks"

## �� Credentials Configuration

### 1. Docker Hub Credentials

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Click **System** → **Global credentials** → **Add Credentials**
3. Configure:
   - **Kind**: Username with password
   - **ID**: `docker-hub-credentials`
   - **Username**: Your Docker Hub username
   - **Password**: Your Docker Hub password/token
   - **Description**: Docker Hub credentials

### 2. SSH Credentials

1. In **Manage Credentials** → **Add Credentials**
2. Configure:
   - **Kind**: SSH Username with private key
   - **ID**: `ssh-credentials`
   - **Username**: `ubuntu`
   - **Private Key**: Upload your private key (`keys/id_rsa`)
   - **Description**: SSH key for EC2 instances

### 3. Server IP Credentials

#### Bastion Host IP

1. **Add Credentials** → **Secret text**
2. Configure:
   - **ID**: `bastion-host-ip`
   - **Secret**: `YOUR_BASTION_IP` (from terraform output)
   - **Description**: Bastion host IP address

#### App Server IP

1. **Add Credentials** → **Secret text**
2. Configure:
   - **ID**: `app-server-ip`
   - **Secret**: `YOUR_APP_IP` (from terraform output)
   - **Description**: App server private IP

## 🔄 Pipeline Job Setup

### 1. Create Pipeline Job

1. Click **New Item**
2. **Name**: `nodejs-pipeline`
3. **Type**: Pipeline
4. Click **OK**

### 2. Configure Pipeline

#### General Tab

- ✅ **GitHub project**
- **Project url**: `https://github.com/YOUR_USERNAME/YOUR_REPO`

#### Pipeline Tab

- **Definition**: Pipeline script from SCM
- **SCM**: Git
- **Repository URL**: `https://github.com/YOUR_USERNAME/YOUR_REPO.git`
- **Branch**: `*/main`
- **Script Path**: `Jenkinsfile`

#### Build Triggers Tab

- ✅ **GitHub hook trigger for GITScm polling**
- ✅ **Poll SCM** (optional backup)
  - **Schedule**: `H/5 * * * *` (every 5 minutes)

## 🔗 GitHub Webhook Configuration

### 1. Configure Webhook in GitHub

1. Go to your GitHub repository
2. **Settings** → **Webhooks** → **Add webhook**
3. Configure:
   - **Payload URL**: `http://JENKINS_IP:8080/github-webhook/`
   - **Content type**: `application/json`
   - **Events**: Just the push event
   - **Active**: ✅

### 2. Test Webhook

```bash
# Test webhook manually
curl -X POST http://JENKINS_IP:8080/github-webhook/ \
  -H "Content-Type: application/json" \
  -d '{
    "ref": "refs/heads/main",
    "repository": {
      "full_name": "YOUR_USERNAME/YOUR_REPO"
    }
  }'
```

## 🧪 Testing the Pipeline

### 1. Manual Trigger

1. Go to your pipeline job
2. Click **Build Now**
3. Monitor the build progress

### 2. Webhook Trigger

1. Make a small change to your code
2. Commit and push to main branch
3. Check Jenkins dashboard - pipeline should start automatically

### 3. Verify Deployment

```bash
# Check if app is running
ssh -i keys/id_rsa ubuntu@BASTION_IP "ssh ubuntu@APP_IP 'docker ps'"

# Test application
curl http://ALB_DNS_NAME/health
```

## 🔍 Pipeline Stages Explained

### 1. Checkout Stage

- Pulls latest code from GitHub repository

### 2. Build Docker Image Stage

- Builds Docker image with tag `ratishjain/nodejs-app:BUILD_NUMBER`
- Tags image as `latest`

### 3. Push to Docker Hub Stage

- Logs into Docker Hub using stored credentials
- Pushes both tagged and latest images

### 4. Deploy to App Server Stage

- Connects to App Server via Bastion host
- Stops existing container
- Pulls latest image
- Starts new container
- Cleans up old images

## 🛠️ Troubleshooting

### Common Issues

#### 1. Webhook Not Triggering

```bash
# Check Jenkins logs
ssh -i keys/id_rsa ubuntu@JENKINS_IP "sudo tail -f /var/log/jenkins/jenkins.log"

# Test webhook endpoint
curl -v http://JENKINS_IP:8080/github-webhook/
```

#### 2. Docker Build Fails

```bash
# Check Docker daemon
ssh -i keys/id_rsa ubuntu@JENKINS_IP "sudo systemctl status docker"

# Check Docker Hub credentials
ssh -i keys/id_rsa ubuntu@JENKINS_IP "docker login"
```

#### 3. SSH Connection Issues

```bash
# Test SSH connection
ssh -i keys/id_rsa ubuntu@BASTION_IP "ssh ubuntu@APP_IP 'echo Connection successful'"

# Check SSH agent in Jenkins
# Go to pipeline build → Console Output
```

#### 4. App Server Deployment Fails

```bash
# Check app server logs
ssh -i keys/id_rsa ubuntu@BASTION_IP "ssh ubuntu@APP_IP 'docker logs nodejs-app'"

# Check if port 3000 is accessible
ssh -i keys/id_rsa ubuntu@BASTION_IP "ssh ubuntu@APP_IP 'netstat -tlnp | grep 3000'"
```

### Useful Commands

```bash
# Get Jenkins initial password
ssh -i keys/id_rsa ubuntu@JENKINS_IP "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

# Restart Jenkins
ssh -i keys/id_rsa ubuntu@JENKINS_IP "sudo systemctl restart jenkins"

# Check Jenkins status
ssh -i keys/id_rsa ubuntu@JENKINS_IP "sudo systemctl status jenkins"

# View Jenkins logs
ssh -i keys/id_rsa ubuntu@JENKINS_IP "sudo tail -f /var/log/jenkins/jenkins.log"

# Check Docker images on app server
ssh -i keys/id_rsa ubuntu@BASTION_IP "ssh ubuntu@APP_IP 'docker images'"

# Test application health
curl http://ALB_DNS_NAME/health
```

## 📊 Monitoring and Maintenance

### 1. Jenkins Performance

- Monitor build times and resource usage
- Clean up old builds periodically
- Update plugins regularly

### 2. Security

- Regularly update Jenkins and plugins
- Monitor access logs
- Rotate credentials periodically

### 3. Application Health

- Monitor application logs
- Set up health checks
- Monitor resource usage on app server

## 🔄 Pipeline Customization

### Environment Variables

You can customize the pipeline by modifying the `environment` section in `Jenkinsfile`:

```groovy
environment {
    DOCKER_IMAGE = 'your-dockerhub-username/your-app'
    DOCKER_TAG   = "${BUILD_NUMBER}"
    APP_PORT     = '3000'
    CONTAINER_NAME = 'nodejs-app'
}
```

### Additional Stages

Add more stages as needed:

- **Testing**: Unit tests, integration tests
- **Security Scanning**: Vulnerability scans
- **Notifications**: Slack, email notifications
- **Rollback**: Automatic rollback on failure

## 📞 Support

For issues or questions:

1. Check Jenkins build logs
2. Review system logs on instances
3. Verify credentials configuration
4. Test individual components manually

---

**Happy Deploying! 🚀**
