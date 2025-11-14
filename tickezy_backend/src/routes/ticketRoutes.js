const express = require('express');
const router = express.Router();
const ticketController = require('../controller/ticketController');
const { authenticate, adminOnly } = require('../middleware/authMiddleware');

/**
 *  Ticket Routes
 */

// Verify ticket QR (staff/admin only)
router.post('/verify', authenticate, ticketController.verifyTicket);

// Create a ticket (any authenticated user)
router.post('/', authenticate, ticketController.createTicket);

// Get all tickets (admins see all, users see only theirs)
router.get('/', authenticate, ticketController.getAllTickets);

// Get a single ticket by ID (admins or ticket owners)
router.get('/:id', authenticate, ticketController.getTicketById);

// Update ticket status (admins or staff)
router.put('/:id/status', authenticate, ticketController.updateTicketStatus);
// Alias to support iOS client calling PUT /tickets/:id
router.put('/:id', authenticate, ticketController.updateTicketStatus);

// Delete a ticket (admin only)
router.delete('/:id', authenticate, adminOnly, ticketController.deleteTicket);

module.exports = router;
