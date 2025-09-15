const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const pino = require("pino");
const pinoHttp = require("pino-http");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 3000;

const dest = pino.destination("/app/logs/app.log");
// Configure Pino logger
const logger = pino(
  {
    level: process.env.LOG_LEVEL || "info",
    formatters: {
      level: (label) => {
        return { level: label };
      },
    },
    timestamp: pino.stdTimeFunctions.isoTime,
    base: {
      service: "nodejs-elk-app",
      version: "1.0.0",
      environment: process.env.NODE_ENV || "development",
    },
    transport:
      process.env.NODE_ENV === "development"
        ? {
            target: "pino-pretty",
            options: {
              colorize: true,
              translateTime: "SYS:standard",
              ignore: "pid,hostname",
            },
          }
        : undefined,
  },
  dest
);

// Create HTTP logger middleware
const httpLogger = pinoHttp({
  logger: logger,
  customLogLevel: function (req, res, err) {
    if (res.statusCode >= 400 && res.statusCode < 500) {
      return "warn";
    } else if (res.statusCode >= 500 || err) {
      return "error";
    } else if (res.statusCode >= 300 && res.statusCode < 400) {
      return "silent";
    }
    return "info";
  },
  customSuccessMessage: function (req, res) {
    if (res.statusCode === 404) {
      return "resource not found";
    }
    return `${req.method} ${req.url}`;
  },
  customErrorMessage: function (req, res, err) {
    return `${req.method} ${req.url} - ${err.message}`;
  },
  customAttributeKeys: {
    req: "request",
    res: "response",
    err: "error",
    responseTime: "responseTime",
  },
  customProps: function (req, res) {
    return {
      requestId: req.id,
      userAgent: req.get("User-Agent"),
      ip: req.ip,
    };
  },
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Use Pino HTTP logger
app.use(httpLogger);

// Routes

// Root endpoint
app.get("/", (req, res) => {
  logger.info("Root endpoint accessed");
  res.json({
    message: "Node.js ELK Logging App with Pino",
    status: "running",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || "development",
    version: "1.0.0",
  });
});

// Health check endpoint
app.get("/health", (req, res) => {
  logger.info("Health check endpoint accessed");
  res.status(200).json({
    status: "healthy",
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    memory: process.memoryUsage(),
    version: process.version,
  });
});

// Test logging endpoint
app.get("/test-logs", (req, res) => {
  logger.info({ test: true, level: "info" }, "Test info log");
  logger.warn({ test: true, level: "warn" }, "Test warning log");
  logger.error({ test: true, level: "error" }, "Test error log");

  res.json({
    message: "Test logs generated with Pino",
    timestamp: new Date().toISOString(),
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  logger.error(
    {
      error: err.message,
      stack: err.stack,
      url: req.url,
      method: req.method,
      requestId: req.id,
    },
    "Unhandled error"
  );

  res.status(500).json({
    error: "Something went wrong!",
    message:
      process.env.NODE_ENV === "development"
        ? err.message
        : "Internal server error",
    timestamp: new Date().toISOString(),
  });
});

// 404 handler
app.use("*", (req, res) => {
  logger.warn(
    {
      url: req.originalUrl,
      method: req.method,
      requestId: req.id,
    },
    "404 - Route not found"
  );

  res.status(404).json({
    error: "Route not found",
    path: req.originalUrl,
    method: req.method,
    timestamp: new Date().toISOString(),
  });
});

// Start server
app.listen(PORT, "0.0.0.0", () => {
  logger.info(
    {
      port: PORT,
      environment: process.env.NODE_ENV || "development",
    },
    "Server started"
  );

  console.log(`🚀 Server is running on port ${PORT}`);
  console.log(`🏥 Health check: http://localhost:${PORT}/health`);
  console.log(`📝 Test logs: http://localhost:${PORT}/test-logs`);
  console.log(`Environment: ${process.env.NODE_ENV || "development"}`);
});

// Graceful shutdown
process.on("SIGTERM", () => {
  logger.info("SIGTERM received, shutting down gracefully");
  console.log("SIGTERM received, shutting down gracefully");
  process.exit(0);
});

process.on("SIGINT", () => {
  logger.info("SIGINT received, shutting down gracefully");
  console.log("SIGINT received, shutting down gracefully");
  process.exit(0);
});

module.exports = app;
