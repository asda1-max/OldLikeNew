require('dotenv').config();

module.exports = {
  API_BASE_URL: process.env.API_BASE_URL || 'http://localhost:8000',
  SESSION_SECRET: process.env.SESSION_SECRET || 'default-secret',
  PORT: parseInt(process.env.PORT, 10) || 3000,
  NODE_ENV: process.env.NODE_ENV || 'development',
};
