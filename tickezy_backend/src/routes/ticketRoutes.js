const express = require('express');
const router = express.Router();
const ticketController = require('../controller/ticketController');
const { authenticate, adminOnly } = require('../middleware/authMiddleware');

/**
 * Routes for tickets
 */

// Create a ticket (any authenticated user)
router.post('/', authenticate, ticketController.createTicket);

// Get all tickets
// Admins see all tickets; regular users see only their own
router.get('/', authenticate, ticketController.getAllTickets);

// Get a single ticket by ID
// Admins can access any; users only their own tickets
router.get('/:id', authenticate, ticketController.getTicketById);

// Update ticket status
// Ideally, only admins or event staff should be able to update status
router.put('/:id/status', authenticate, ticketController.updateTicketStatus);

// Delete ticket
// Only admins can delete
router.delete('/:id', authenticate, adminOnly, ticketController.deleteTicket);

module.exports = router;
