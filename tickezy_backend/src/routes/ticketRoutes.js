const express = require('express');
const router = express.Router();
const ticketController = require('../controller/ticketController');

// Create a new ticket
router.post('/', ticketController.createTicket);

// Get all tickets
router.get('/', ticketController.getAllTickets);

// Get a single ticket by ID
router.get('/:id', ticketController.getTicketById);

// Update ticket status
router.put('/:id/status', ticketController.updateTicketStatus);

// Delete a ticket
router.delete('/:id', ticketController.deleteTicket);

module.exports = router;
