# Node.js Prometheus Grafana Monitoring Setup

This project demonstrates how to set up comprehensive monitoring for a Node.js application using Prometheus for metrics collection and Grafana for visualization, all deployed on Kubernetes.

## Architecture Overview

## Prerequisites

- Docker installed and running
- Kubernetes cluster (minikube, kind, or cloud provider)
- Helm 3.x installed
- kubectl configured

## Project Structure

```
nodejs-prometheus-grafana/
├── app.js                    # Node.js application with metrics
├── package.json              # Dependencies
├── Dockerfile               # Docker configuration
├── .env                     # Environment variables
├── k8s/
│   ├── deployment.yaml      # Kubernetes deployment
│   └── service.yaml         # Kubernetes service
└── README.md               # This file
```

## Step 1: Node.js Application Setup

### 1.1 Create the Application

The Node.js app includes:

- Express server with health endpoints
- Prometheus metrics integration using `prom-client`
- Custom metrics: HTTP requests, response times, active connections
- Default Node.js metrics (CPU, memory, GC)

**Key Features:**

- `/` - Root endpoint
- `/health` - Health check endpoint
- `/metrics` - Prometheus metrics endpoint

### 1.2 Dependencies

```json
{
  "dependencies": {
    "express": "^4.18.2",
    "prom-client": "^15.0.0",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "morgan": "^1.10.0",
    "dotenv": "^16.3.1"
  }
}
```

## Step 2: Docker Configuration

### 2.1 Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["node", "app.js"]
```

### 2.2 Build and Push to Docker Hub

```bash
# Build the Docker image
docker build -t your-username/nodejs-prometheus-app:latest .

# Tag for Docker Hub
docker tag your-username/nodejs-prometheus-app:latest your-username/nodejs-prometheus-app:v1.0.0

# Push to Docker Hub
docker push your-username/nodejs-prometheus-app:latest
docker push your-username/nodejs-prometheus-app:v1.0.0
```

## Step 3: Kubernetes Deployment

### 3.1 Create Namespaces

```bash
# Create monitoring namespace
kubectl create namespace monitoring

# Default namespace is used for the Node.js app
```

### 3.2 Node.js App Deployment

**deployment.yaml:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: node-app
  name: node-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: node-app
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: node-app
    spec:
      containers:
        - image: ratishjain/nodejs-prometheus-grafana
          name: nodejs-prometheus-grafana
          resources: {}
status: {}
```

**service.yaml:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: node-app-service
spec:
  selector:
    app: node-app
  ports:
    - port: 3000
      protocol: TCP
      targetPort: 3000
  type: NodePort
```

### 3.3 Deploy the Node.js App

```bash
# Apply the Kubernetes manifests
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Verify deployment
kubectl get pods -n default
kubectl get svc -n default
```

## Step 4: Prometheus Setup with Helm

### 4.1 Add Prometheus Helm Repository

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### 4.2 Install Prometheus

```bash
helm install prometheus prometheus-community/prometheus \
  --version 27.37.0 \
  --namespace monitoring \
  --set server.service.type=NodePort \
  --set server.service.nodePort=30090 \
  --set alertmanager.enabled=false
```

### 4.3 Configure Prometheus to Scrape Node.js App

Create a ConfigMap for Prometheus configuration:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s

    scrape_configs:
    - job_name: 'prometheus'
      static_configs:
      - targets: ['localhost:9090']

    - job_name: 'node-app'
      kubernetes_sd_configs:
      - role: endpoints
        namespaces:
          names:
          - default
      relabel_configs:
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)
      - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
        action: replace
        regex: ([^:]+)(?::\d+)?;(\d+)
        replacement: $1:$2
        target_label: __address__
      - action: labelmap
        regex: __meta_kubernetes_service_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
      - source_labels: [__meta_kubernetes_service_name]
        action: replace
        target_label: kubernetes_name
```

Apply the configuration:

```bash
kubectl apply -f prometheus-configmap.yaml
kubectl rollout restart deployment/prometheus-server -n monitoring
```

## Step 5: Grafana Setup with Helm

### 5.1 Add Grafana Helm Repository

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

### 5.2 Install Grafana

```bash
helm install grafana grafana/grafana \
  --namespace monitoring \
  --set service.type=NodePort \
  --set service.nodePort=30091 \
  --set persistence.enabled=false
```

### 5.3 Get Grafana Admin Password

```bash
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

## Step 6: Access the Services

### 6.1 Port Forwarding Commands

```bash
# Node.js App
kubectl port-forward svc/node-app-service 3000:3000 -n default

# Prometheus
kubectl port-forward svc/prometheus-server 9090:9090 -n monitoring

# Grafana
kubectl port-forward svc/grafana 3001:80 -n monitoring
```

### 6.2 Service URLs

- **Node.js App**: http://localhost:3000
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin-password)

## Step 7: Configure Grafana

### 7.1 Add Prometheus Data Source

1. Login to Grafana (admin/admin-password)
2. Go to Configuration → Data Sources
3. Add Prometheus data source:
   - URL: `http://prometheus-server.monitoring.svc.cluster.local:9090`
   - Name: `prometheus-server`

### 7.2 Import Custom Dashboard

1. Go to + → Import
2. Use the provided dashboard JSON (see below)
3. Select `prometheus-server` as data source

## Step 8: Generate Test Traffic

```bash
# Port forward to Node.js app
kubectl port-forward svc/node-app-service 3000:3000 -n default

# Generate traffic
for i in {1..50}; do
  curl http://localhost:3000/
  curl http://localhost:3000/health
  sleep 1
done
```

## Step 9: Verify Monitoring

### 9.1 Check Prometheus Targets

1. Go to http://localhost:9090/targets
2. Verify `node-app` job is UP
3. Check metrics at http://localhost:9090/graph

### 9.2 Check Grafana Dashboard

1. Go to http://localhost:3000
2. Login with admin credentials
3. View the imported dashboard
4. Verify all panels show data

## Troubleshooting

### Common Issues

1. **Prometheus can't scrape Node.js app**

   - Check if the app is running: `kubectl get pods -n default`
   - Verify service: `kubectl get svc -n default`
   - Check Prometheus targets page

2. **No metrics in Grafana**

   - Verify Prometheus data source configuration
   - Check if metrics exist in Prometheus
   - Generate some traffic to the Node.js app

3. **Port forwarding issues**
   - Ensure correct port mapping
   - Check if services are running
   - Verify namespace names

### Useful Commands

```bash
# Check pod logs
kubectl logs -f deployment/node-app -n default

# Check Prometheus logs
kubectl logs -f deployment/prometheus-server -n monitoring

# Check service endpoints
kubectl get endpoints -n default

# Test metrics endpoint
curl http://localhost:3000/metrics
```

## Custom Dashboard JSON

The dashboard includes panels for:

- HTTP Requests Total
- Active Connections
- HTTP Request Duration (95th percentile, 50th percentile, average)
- HTTP Request Rate
- HTTP Status Codes
- HTTP Methods

## Next Steps

- Set up alerting rules in Prometheus
- Configure Grafana alerts
- Add more custom metrics to the Node.js app
- Set up log aggregation with ELK stack
- Implement distributed tracing

## Cleanup

```bash
# Remove Helm releases
helm uninstall prometheus -n monitoring
helm uninstall grafana -n monitoring

# Remove Kubernetes resources
kubectl delete -f k8s/deployment.yaml
kubectl delete -f k8s/service.yaml

# Remove namespaces
kubectl delete namespace monitoring
```

---

This setup provides a complete monitoring solution for your Node.js application with Prometheus collecting metrics and Grafana providing beautiful visualizations.
