const express = require('express');
const { createApiClient } = require('../services/api');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.use(requireAuth);

// GET /auctions — List all auctions with status filter
router.get('/', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);
    const statusFilter = req.query.status || 'active';

    const { data: auctions } = await api.get(`/auctions/?status=${statusFilter}`);

    res.render('auctions/index', {
      title: 'Auction Management — LelangKu Admin',
      currentPath: '/auctions',
      auctions,
      statusFilter,
    });
  } catch (err) {
    next(err);
  }
});

// GET /auctions/:id — Auction detail with bid history
router.get('/:id', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);
    const { data: auction } = await api.get(`/auctions/${req.params.id}`);

    // Fetch bid history
    let bids = [];
    try {
      const bidsRes = await api.get(`/bids/${req.params.id}`);
      bids = bidsRes.data;
    } catch (e) {
      // no bids
    }

    res.render('auctions/detail', {
      title: `Auction #${auction.id} — Detail`,
      currentPath: '/auctions',
      auction,
      bids,
    });
  } catch (err) {
    next(err);
  }
});

// POST /auctions/:id/cancel — Cancel an auction
router.post('/:id/cancel', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);
    await api.put(`/auctions/${req.params.id}`, {
      status: 'cancelled',
    });
    res.redirect(`/auctions/${req.params.id}`);
  } catch (err) {
    // If cancel fails (e.g., has bids), redirect with error
    const message = err.response?.data?.detail || 'Failed to cancel auction';
    res.redirect(`/auctions/${req.params.id}?error=${encodeURIComponent(message)}`);
  }
});


module.exports = router;
