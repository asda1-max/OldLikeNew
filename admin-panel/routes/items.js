const express = require('express');
const { createApiClient } = require('../services/api');
const { requireAuth } = require('../middleware/auth');

const router = express.Router();

router.use(requireAuth);

// GET /items — List all items
router.get('/', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);

    // Fetch all items directly from the new admin endpoint
    const itemsRes = await api.get('/items/all');
    let items = itemsRes.data;

    // Fetch auctions to attach
    const statuses = ['active', 'closed', 'cancelled', 'draft'];
    const results = await Promise.allSettled(
      statuses.map((s) => api.get(`/auctions/?status=${s}`))
    );

    const auctionsByItem = new Map();

    results.forEach((r) => {
      if (r.status === 'fulfilled') {
        r.value.data.forEach((auction) => {
          const itemId = auction.item ? auction.item.id : auction.item_id;
          if (itemId) {
            if (!auctionsByItem.has(itemId)) {
              auctionsByItem.set(itemId, []);
            }
            auctionsByItem.get(itemId).push(auction);
          }
        });
      }
    });

    // Attach auction info
    items = items.map((item) => ({
      ...item,
      auctions: auctionsByItem.get(item.id) || [],
    }));

    // Filters
    const categoryFilter = req.query.category || 'all';
    const conditionFilter = req.query.condition || 'all';
    const search = (req.query.search || '').toLowerCase();

    if (categoryFilter !== 'all') {
      items = items.filter((i) => i.category === categoryFilter);
    }
    if (conditionFilter !== 'all') {
      items = items.filter((i) => i.condition === conditionFilter);
    }
    if (search) {
      items = items.filter(
        (i) =>
          i.title.toLowerCase().includes(search) ||
          (i.description || '').toLowerCase().includes(search)
      );
    }

    // Get unique categories for filter
    const categories = [...new Set(items.map((i) => i.category))];

    res.render('items/index', {
      title: 'Item Management — LelangKu Admin',
      currentPath: '/items',
      items,
      categories,
      categoryFilter,
      conditionFilter,
      search,
    });
  } catch (err) {
    next(err);
  }
});

// GET /items/:id — Item detail
router.get('/:id', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);
    const { data: item } = await api.get(`/items/${req.params.id}`);

    // Fetch auctions for this item
    const statuses = ['active', 'closed', 'cancelled', 'draft'];
    const results = await Promise.allSettled(
      statuses.map((s) => api.get(`/auctions/?status=${s}`))
    );

    const relatedAuctions = [];
    results.forEach((r) => {
      if (r.status === 'fulfilled') {
        r.value.data.forEach((auction) => {
          if (auction.item && auction.item.id === parseInt(req.params.id)) {
            relatedAuctions.push(auction);
          }
        });
      }
    });

    // Fetch seller info
    let seller = null;
    try {
      const sellerRes = await api.get(`/users/${item.seller_id}`);
      seller = sellerRes.data;
    } catch (e) {
      // seller info not available
    }

    res.render('items/detail', {
      title: `${item.title} — Item Detail`,
      currentPath: '/items',
      item,
      seller,
      relatedAuctions,
    });
  } catch (err) {
    next(err);
  }
});

// POST /items/:id/verify — Verify item
router.post('/:id/verify', async (req, res, next) => {
  try {
    const api = createApiClient(req.session.token);
    await api.put(`/items/${req.params.id}/verify`);
    res.redirect(`/items/${req.params.id}`);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
