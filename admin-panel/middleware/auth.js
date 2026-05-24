/**
 * Auth middleware — checks if user is logged in via session token.
 * Injects currentUser into res.locals for EJS templates.
 */
function requireAuth(req, res, next) {
  if (!req.session || !req.session.token) {
    return res.redirect('/auth/login');
  }

  // Make user info available to all templates
  res.locals.currentUser = req.session.user || {};
  res.locals.token = req.session.token;
  next();
}

/**
 * Guest-only middleware — redirects to dashboard if already logged in.
 */
function guestOnly(req, res, next) {
  if (req.session && req.session.token) {
    return res.redirect('/dashboard');
  }
  next();
}

module.exports = { requireAuth, guestOnly };
