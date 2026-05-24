const express = require('express');
const { createApiClient } = require('../services/api');
const { guestOnly } = require('../middleware/auth');

const router = express.Router();

// GET /auth/login — Render login page
router.get('/login', guestOnly, (req, res) => {
  res.render('auth/login', {
    title: 'Login — LelangKu Admin',
    error: req.query.error || null,
    currentPath: '/auth/login',
  });
});

// POST /auth/login — Authenticate with backend
router.post('/login', guestOnly, async (req, res) => {
  try {
    const { email, password } = req.body;

    // Backend expects OAuth2 form: username & password (x-www-form-urlencoded)
    const api = createApiClient();
    const params = new URLSearchParams();
    params.append('username', email);
    params.append('password', password);

    const loginRes = await api.post('/auth/login', params, {
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    });

    const token = loginRes.data.access_token;

    // Fetch user profile to verify admin role
    const profileApi = createApiClient(token);
    const profileRes = await profileApi.get('/auth/me');
    const user = profileRes.data;

    if (user.role !== 'admin') {
      return res.redirect('/auth/login?error=Access denied. Admin only.');
    }

    // Store in session
    req.session.token = token;
    req.session.user = user;

    res.redirect('/dashboard');
  } catch (err) {
    const message = err.response?.data?.detail || 'Invalid credentials';
    res.redirect(`/auth/login?error=${encodeURIComponent(message)}`);
  }
});

// GET /auth/logout — Destroy session
router.get('/logout', (req, res) => {
  req.session.destroy(() => {
    res.redirect('/auth/login');
  });
});

module.exports = router;
