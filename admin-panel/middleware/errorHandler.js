/**
 * Global error handler middleware for Express.
 */
function errorHandler(err, req, res, _next) {
  console.error('❌ Error:', err.message || err);

  const statusCode = err.statusCode || err.response?.status || 500;
  const message = err.response?.data?.detail || err.message || 'Internal Server Error';

  // If it's an API auth error, redirect to login
  if (statusCode === 401) {
    req.session.destroy();
    return res.redirect('/auth/login');
  }

  res.status(statusCode).render('error', {
    title: 'Error',
    statusCode,
    message,
    currentPath: req.path,
  });
}

module.exports = errorHandler;
