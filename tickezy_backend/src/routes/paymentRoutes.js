const express = require('express');
const router = express.Router();
const paymentController = require('../controller/paymentController');
const { authenticate, adminOnly } = require('../middleware/authMiddleware');

/**
 *  Payment Routes
 */

// Create a payment (any authenticated user)
router.post('/', authenticate, paymentController.createPayment);

// Get all payments (admins see all, users see only theirs)
router.get('/', authenticate, paymentController.getAllPayments);

// Get a single payment by ID (admins or payment owners)
router.get('/:id', authenticate, paymentController.getPaymentById);

// Update payment status (admins or staff)
router.put('/:id/status', authenticate, paymentController.updatePaymentStatus);

// Delete a payment (admin only)
router.delete('/:id', authenticate, adminOnly, paymentController.deletePayment);

// Filter payments (admin only)
router.get('/filter/search', authenticate, adminOnly, paymentController.filterPayments);

module.exports = router;
