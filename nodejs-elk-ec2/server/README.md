# Node.js ELK Logging App

A simple Node.js Express application with Pino logging for ELK stack integration.

## Features

- **Express.js** web server
- **Pino** structured logging
- **ELK Stack** integration (Elasticsearch, Logstash, Kibana)
- **Docker** containerization
- **Health checks** and monitoring endpoints

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Start Development Server

```bash
npm run dev
```

### 3. Start with Docker Compose (ELK Stack)

```bash
docker-compose up -d
```

## API Endpoints

- `GET /` - Root endpoint
- `GET /health` - Health check
- `GET /test-logs` - Generate test logs

## Environment Variables

Create a `.env` file:

```env
NODE_ENV=development
PORT=3000
LOG_LEVEL=info
ELASTICSEARCH_URL=http://localhost:9200
ELASTICSEARCH_INDEX=nodejs-logs
AWS_REGION=us-west-2
```

## Logging

The app uses Pino for structured JSON logging. Logs are written to:

- Console (pretty printed in development)
- `logs/combined.log` (all logs)
- `logs/error.log` (error logs only)

## ELK Stack

- **Elasticsearch**: `http://localhost:9200`
- **Kibana**: `http://localhost:5601`
- **Logstash**: Port 5044
- **Filebeat**: Collects logs from the app

## Docker

Build and run:

```bash
docker build -t nodejs-elk-app .
docker run -p 3000:3000 nodejs-elk-app
```

## Development

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# Test logging
curl http://localhost:3000/test-logs
```
