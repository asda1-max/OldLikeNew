const express = require('express');
const { createApiClient } = require('../services/api');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.use(requireAuth);

// GET /transactions — List all transactions
router.get('/', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);
    const { data: transactions } = await api.get('/transactions/');

    const paymentFilter = req.query.payment || 'all';
    const shippingFilter = req.query.shipping || 'all';

    let filtered = transactions;
    if (paymentFilter !== 'all') {
      filtered = filtered.filter((t) => t.payment_status === paymentFilter);
    }
    if (shippingFilter !== 'all') {
      filtered = filtered.filter((t) => t.shipping_status === shippingFilter);
    }

    // Sort by most recent
    filtered.sort((a, b) => new Date(b.created_at) - new Date(a.created_at));

    res.render('transactions/index', {
      title: 'Transactions — LelangKu Admin',
      currentPath: '/transactions',
      transactions: filtered,
      paymentFilter,
      shippingFilter,
      totalTransactions: transactions.length,
    });
  } catch (err) {
    next(err);
  }
});

// GET /transactions/:id — Transaction detail
router.get('/:id', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);
    const { data: transactions } = await api.get('/transactions/');

    const transaction = transactions.find(
      (t) => t.id === parseInt(req.params.id)
    );

    if (!transaction) {
      const err = new Error('Transaction not found');
      err.statusCode = 404;
      throw err;
    }

    // Fetch related auction detail
    let auction = null;
    try {
      const auctionRes = await api.get(`/auctions/${transaction.auction_id}`);
      auction = auctionRes.data;
    } catch (e) {
      // auction might not be accessible
    }

    // Fetch buyer & seller info
    let buyer = null;
    let seller = null;
    try {
      const buyerRes = await api.get(`/users/${transaction.buyer_id}`);
      buyer = buyerRes.data;
    } catch (e) {}
    try {
      const sellerRes = await api.get(`/users/${transaction.seller_id}`);
      seller = sellerRes.data;
    } catch (e) {}

    res.render('transactions/detail', {
      title: `Transaction #${transaction.id} — Detail`,
      currentPath: '/transactions',
      transaction,
      auction,
      buyer,
      seller,
      error: req.query.error || null,
      success: req.query.success || null,
    });
  } catch (err) {
    next(err);
  }
});

// POST /transactions/:id/status — Update transaction status
router.post('/:id/status', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);
    const { payment_status, shipping_status } = req.body;

    const updateData = {};
    if (payment_status) updateData.payment_status = payment_status;
    if (shipping_status) updateData.shipping_status = shipping_status;

    await api.put(`/transactions/${req.params.id}/status`, updateData);
    res.redirect(`/transactions/${req.params.id}?success=Status updated successfully`);
  } catch (err) {
    const message = err.response?.data?.detail || 'Failed to update status';
    res.redirect(`/transactions/${req.params.id}?error=${encodeURIComponent(message)}`);
  }
});

module.exports = router;
