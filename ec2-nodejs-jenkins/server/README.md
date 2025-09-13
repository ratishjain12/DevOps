# EC2 Node.js Jenkins Server

A basic Node.js Express server designed for DevOps deployment on EC2 with Jenkins CI/CD.

## Features

- **Express.js** - Fast, unopinionated web framework
- **Security** - Helmet.js for security headers
- **CORS** - Cross-Origin Resource Sharing enabled
- **Logging** - Morgan for HTTP request logging
- **Health Checks** - Built-in health monitoring endpoints
- **Environment Configuration** - Configurable via environment variables
- **Graceful Shutdown** - Proper SIGTERM/SIGINT handling

## Quick Start

### Prerequisites

- Node.js (>= 16.0.0)
- pnpm (package manager)

### Installation

1. Navigate to the server directory:

   ```bash
   cd server
   ```

2. Install dependencies:

   ```bash
   pnpm install
   ```

3. Start the development server:

   ```bash
   pnpm run dev
   ```

4. Or start the production server:
   ```bash
   pnpm start
   ```

The server will start on `http://localhost:3000` by default.

## API Endpoints

### Health & Status

- `GET /` - Welcome message and server info
- `GET /health` - Health check with system metrics
- `GET /api/status` - API status and available endpoints

### Sample API

- `GET /api/users` - Get list of users
- `POST /api/users` - Create a new user

## Environment Variables

Create a `.env` file in the server directory with:

```env
NODE_ENV=development
PORT=3000
HOST=0.0.0.0
LOG_LEVEL=info
CORS_ORIGIN=*
JWT_SECRET=your-secret-key-here
```

## Development

### Available Scripts

- `pnpm start` - Start the production server
- `pnpm run dev` - Start the development server with nodemon
- `pnpm test` - Run tests (placeholder)

### Project Structure

```
server/
├── app.js          # Main application file
├── config.js       # Configuration settings
├── package.json    # Dependencies and scripts
└── README.md       # This file
```

## Docker Support

This server is designed to work with Docker containers for easy deployment.

### Dockerfile Example

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

## Jenkins Integration

This server is ready for Jenkins CI/CD pipeline integration with:

- Health check endpoints for deployment verification
- Proper logging for monitoring
- Environment-based configuration
- Graceful shutdown handling

## Monitoring

The server provides several monitoring endpoints:

- **Health Check**: `/health` - Returns server health and system metrics
- **Status**: `/api/status` - Returns API status and available endpoints

## Security

- Helmet.js for security headers
- CORS configuration
- Input validation
- Error handling without sensitive data exposure

## License

ISC
