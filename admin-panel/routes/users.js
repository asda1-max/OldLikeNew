const express = require('express');
const { createApiClient } = require('../services/api');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.use(requireAuth);

// GET /users — List all users
router.get('/', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);
    const { data: users } = await api.get('/users/');

    const roleFilter = req.query.role || 'all';
    const search = (req.query.search || '').toLowerCase();

    let filtered = users;
    if (roleFilter !== 'all') {
      filtered = filtered.filter((u) => u.role === roleFilter);
    }
    if (search) {
      filtered = filtered.filter(
        (u) =>
          u.name.toLowerCase().includes(search) ||
          u.email.toLowerCase().includes(search)
      );
    }

    res.render('users/index', {
      title: 'User Management — LelangKu Admin',
      currentPath: '/users',
      users: filtered,
      roleFilter,
      search,
      totalUsers: users.length,
    });
  } catch (err) {
    next(err);
  }
});

// GET /users/:id — User detail
router.get('/:id', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);
    const { data: user } = await api.get(`/users/${req.params.id}`);

    res.render('users/detail', {
      title: `${user.name} — User Detail`,
      currentPath: '/users',
      user,
    });
  } catch (err) {
    next(err);
  }
});

// POST /users/:id/verify — Toggle user verification
router.post('/:id/verify', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);
    const isVerified = req.body.is_verified === 'true';

    await api.put(`/users/${req.params.id}`, {
      is_verified: isVerified,
    });

    res.redirect(`/users/${req.params.id}`);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
