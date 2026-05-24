const axios = require('axios');
const config = require('../config');

/**
 * Creates an Axios instance configured to talk to the LelangKu backend.
 * Token is passed per-request since each request may come from a different session.
 */
function createApiClient(token) {
  const client = axios.create({
    baseURL: config.API_BASE_URL,
    timeout: 15000,
    headers: {
      'Content-Type': 'application/json',
    },
  });

  // Attach bearer token if provided
  if (token) {
    client.defaults.headers.common['Authorization'] = `Bearer ${token}`;
  }

  // Response interceptor for error normalization
  client.interceptors.response.use(
    (response) => response,
    (error) => {
      if (error.response) {
        const err = new Error(error.response.data?.detail || 'API Error');
        err.statusCode = error.response.status;
        err.response = error.response;
        throw err;
      }
      throw error;
    }
  );

  return client;
}

module.exports = { createApiClient };
