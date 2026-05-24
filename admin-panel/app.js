const express = require('express');
const path = require('path');
const session = require('express-session');
const morgan = require('morgan');
const config = require('./config');
const errorHandler = require('./middleware/errorHandler');

// Route imports
const authRoutes = require('./routes/auth');
const dashboardRoutes = require('./routes/dashboard');
const usersRoutes = require('./routes/users');
const itemsRoutes = require('./routes/items');
const auctionsRoutes = require('./routes/auctions');
const transactionsRoutes = require('./routes/transactions');

const app = express();

// View engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Middleware
app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(express.static(path.join(__dirname, 'public')));

// Session
app.use(
  session({
    secret: config.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {
      maxAge: 24 * 60 * 60 * 1000, // 24 hours
      httpOnly: true,
    },
  })
);

// Global template variables
app.use((req, res, next) => {
  res.locals.currentUser = req.session?.user || null;
  res.locals.API_BASE_URL = config.API_BASE_URL;
  next();
});

// Routes
app.get('/', (req, res) => res.redirect('/dashboard'));
app.use('/auth', authRoutes);
app.use('/dashboard', dashboardRoutes);
app.use('/users', usersRoutes);
app.use('/items', itemsRoutes);
app.use('/auctions', auctionsRoutes);
app.use('/transactions', transactionsRoutes);

// Error page view
app.use((req, res) => {
  res.status(404).render('error', {
    title: '404 — Not Found',
    statusCode: 404,
    message: 'The page you are looking for does not exist.',
    currentPath: req.path,
  });
});

// Global error handler
app.use(errorHandler);

// Start server
app.listen(config.PORT, () => {
  console.log(`\n🚀 LelangKu Admin Panel running at http://localhost:${config.PORT}`);
  console.log(`📡 API Backend: ${config.API_BASE_URL}\n`);
});

module.exports = app;
