const express = require('express');
const router = express.Router();
const userController = require('../controller/userController'); 
const { authenticate, adminOnly } = require('../middleware/authMiddleware'); 

// Public routes
router.post('/register', userController.register);
router.post('/login', userController.login);

// Protected routes
router.get('/profile', authenticate, userController.getProfile);

// Admin-only routes example (optional)
 router.get('/all', authenticate, adminOnly, userController.getAllUsers);

module.exports = router;
