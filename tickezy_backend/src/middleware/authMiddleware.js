const { User } = require('../models');
const jwt = require('jsonwebtoken');

/**
 * Middleware: Verify JWT and attach user to request
 */
async function authenticate(req, res, next) {
  try {
    const authHeader = req.headers.authorization;

    // 1️⃣ Check for missing or malformed Authorization header
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Access token missing or malformed' });
    }

    // 2️⃣ Extract and verify JWT
    const token = authHeader.split(' ')[1];
    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
      return res.status(401).json({ success: false, message: 'Invalid or expired token' });
    }

    // 3️⃣ Find user in DB
    const user = await User.findByPk(decoded.id);
    if (!user) {
      return res.status(401).json({ success: false, message: 'User not found or removed' });
    }

    // 4️⃣ Check if account is disabled (assuming `isActive` column in User model)
    if (user.isActive === false) {
      return res.status(403).json({ success: false, message: 'Account disabled. Contact admin.' });
    }

    // ✅ Attach user to request
    req.user = user;
    next();

  } catch (err) {
    console.error('Auth error:', err.message);
    return res.status(500).json({ success: false, message: 'Authentication failed' });
  }
}

/**
 * Middleware: Restrict route to admin users
 */
function adminOnly(req, res, next) {
  if (!req.user) {
    return res.status(401).json({ success: false, message: 'Unauthorized' });
  }

  // Compare role case-insensitively
  if (req.user.role?.toUpperCase() !== 'ADMIN') {
    return res.status(403).json({ success: false, message: 'Access denied: Admins only' });
  }

  next();
}

module.exports = { authenticate, adminOnly };
