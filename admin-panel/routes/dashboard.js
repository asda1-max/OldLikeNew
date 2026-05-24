const express = require('express');
const { createApiClient } = require('../services/api');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.use(requireAuth);

// GET /dashboard — Main dashboard with analytics
router.get('/', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);

    // Fetch all data in parallel
    const [usersRes, auctionsActiveRes, auctionsAllRes, transactionsRes] = await Promise.allSettled([
      api.get('/users/'),
      api.get('/auctions/?status=active'),
      api.get('/auctions/?status=closed'),
      api.get('/transactions/'),
    ]);

    const users = usersRes.status === 'fulfilled' ? usersRes.value.data : [];
    const activeAuctions = auctionsActiveRes.status === 'fulfilled' ? auctionsActiveRes.value.data : [];
    const closedAuctions = auctionsAllRes.status === 'fulfilled' ? auctionsAllRes.value.data : [];
    const transactions = transactionsRes.status === 'fulfilled' ? transactionsRes.value.data : [];

    // Calculate stats
    const totalUsers = users.length;
    const totalActiveAuctions = activeAuctions.length;
    const totalTransactions = transactions.length;
    const totalRevenue = transactions.reduce((sum, t) => sum + (parseFloat(t.final_price) || 0), 0);

    // Role distribution
    const roleCounts = { admin: 0, seller: 0, buyer: 0 };
    users.forEach((u) => {
      if (roleCounts[u.role] !== undefined) roleCounts[u.role]++;
    });

    // Transaction status distribution
    const paymentStatusCounts = { pending: 0, paid: 0, cancelled: 0 };
    transactions.forEach((t) => {
      if (paymentStatusCounts[t.payment_status] !== undefined) paymentStatusCounts[t.payment_status]++;
    });

    // Category distribution from active auctions
    const categoryCounts = {};
    activeAuctions.forEach((a) => {
      const cat = a.item?.category || 'other';
      categoryCounts[cat] = (categoryCounts[cat] || 0) + 1;
    });

    // Recent transactions (last 5)
    const recentTransactions = transactions
      .sort((a, b) => new Date(b.created_at) - new Date(a.created_at))
      .slice(0, 5);

    res.render('dashboard/index', {
      title: 'Dashboard — LelangKu Admin',
      currentPath: '/dashboard',
      stats: {
        totalUsers,
        totalActiveAuctions,
        totalTransactions,
        totalRevenue,
      },
      roleCounts,
      paymentStatusCounts,
      categoryCounts,
      recentTransactions,
      closedAuctions,
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
