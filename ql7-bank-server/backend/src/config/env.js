// Environment configuration for QL7 Bank Server
require('dotenv').config();

module.exports = {
  // Server Configuration
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: process.env.PORT || 3000,
  HOST: process.env.HOST || '0.0.0.0',

  // Database Configuration
  DB: {
    HOST: process.env.DB_HOST || 'localhost',
    PORT: process.env.DB_PORT || 5432,
    NAME: process.env.DB_NAME || 'ql7_bank',
    USER: process.env.DB_USER || 'ql7_admin',
    PASSWORD: process.env.DB_PASSWORD || 'secure_password',
    DIALECT: process.env.DB_DIALECT || 'postgres',
    POOL: {
      max: parseInt(process.env.DB_POOL_MAX) || 5,
      min: parseInt(process.env.DB_POOL_MIN) || 0,
      acquire: parseInt(process.env.DB_POOL_ACQUIRE) || 30000,
      idle: parseInt(process.env.DB_POOL_IDLE) || 10000
    }
  },

  // JWT Configuration
  JWT: {
    SECRET: process.env.JWT_SECRET || 'ql7_super_secret_key',
    EXPIRES_IN: process.env.JWT_EXPIRES_IN || '24h',
    ALGORITHM: process.env.JWT_ALGORITHM || 'HS256'
  },

  // Security Configuration
  SECURITY: {
    SALT_ROUNDS: parseInt(process.env.SALT_ROUNDS) || 10,
    RATE_LIMIT: {
      WINDOW_MS: parseInt(process.env.RATE_LIMIT_WINDOW) || 15 * 60 * 1000, // 15 minutes
      MAX: parseInt(process.env.RATE_LIMIT_MAX) || 100
    }
  },

  // API Keys
  API_KEYS: {
    TRANSACTION_SERVICE: process.env.TRANSACTION_SERVICE_KEY || '',
    FRAUD_DETECTION: process.env.FRAUD_DETECTION_API_KEY || ''
  },

  // Logging Configuration
  LOGGING: {
    LEVEL: process.env.LOG_LEVEL || 'debug',
    FILE: process.env.LOG_FILE || 'ql7_server.log'
  }
};