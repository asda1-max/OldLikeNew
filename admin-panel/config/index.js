require('dotenv').config();

module.exports = {
  API_BASE_URL: process.env.API_BASE_URL || 'https://lelangku-backend-487072029768.asia-southeast2.run.app',
  SESSION_SECRET: process.env.SESSION_SECRET || 'default-secret',
  PORT: parseInt(process.env.PORT, 10) || 3000,
  NODE_ENV: process.env.NODE_ENV || 'development',
};
