// Configuration file for the Express server
module.exports = {
  // Server configuration
  port: process.env.PORT || 3000,
  host: process.env.HOST || "0.0.0.0",
  nodeEnv: process.env.NODE_ENV || "development",

  // CORS configuration
  cors: {
    origin: process.env.CORS_ORIGIN || "*",
    credentials: true,
  },

  // Logging configuration
  logging: {
    level: process.env.LOG_LEVEL || "info",
    format: process.env.NODE_ENV === "production" ? "combined" : "dev",
  },

  // Security configuration
  security: {
    jwtSecret: process.env.JWT_SECRET || "your-secret-key-here",
    helmet: {
      contentSecurityPolicy: false,
    },
  },

  // API configuration
  api: {
    version: "v1",
    prefix: "/api",
  },
};
