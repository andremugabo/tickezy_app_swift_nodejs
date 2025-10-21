const TicketService = require('../services/ticketService');

/**
 * Create a new ticket (any authenticated user)
 */
exports.createTicket = async (req, res) => {
  try {
    const { eventId, quantity, checkedInBy } = req.body;
    const userId = req.user.id; // authenticated user ID
    const ticket = await TicketService.createTicket({ userId, eventId, quantity, checkedInBy });
    res.status(201).json({ message: 'Ticket created successfully', ticket });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

/**
 * Get all tickets (admins see all, users see only their tickets)
 */
exports.getAllTickets = async (req, res) => {
  try {
    const user = req.user;
    const tickets = await TicketService.getAllTickets(user);
    res.status(200).json(tickets);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

/**
 * Get a single ticket by ID (admins can access any, users only their own)
 */
exports.getTicketById = async (req, res) => {
  try {
    const user = req.user;
    const ticket = await TicketService.getTicketById(req.params.id, user);
    res.status(200).json(ticket);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

/**
 * Update ticket status (only admin or staff)
 */
exports.updateTicketStatus = async (req, res) => {
  try {
    const user = req.user;
    const ticket = await TicketService.updateTicketStatus(req.params.id, req.body.status, user);
    res.status(200).json({ message: 'Ticket status updated', ticket });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

/**
 * Delete a ticket (admin only)
 */
exports.deleteTicket = async (req, res) => {
  try {
    const user = req.user;
    if (user.role?.toUpperCase() !== 'ADMIN') {
      return res.status(403).json({ message: 'Access denied: Admins only' });
    }

    const result = await TicketService.deleteTicket(req.params.id);
    res.status(200).json(result);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

/**
 * Verify ticket QR code (staff or admin)
 */
exports.verifyTicket = async (req, res) => {
  try {
    const user = req.user;

    // Ensure only staff or admin can scan tickets
    const allowedRoles = ['ADMIN', 'STAFF'];
    if (!allowedRoles.includes(user.role?.toUpperCase())) {
      return res.status(403).json({ message: 'Access denied: Only staff or admin can verify tickets' });
    }

    const { qrData } = req.body; // raw QR content from scanner
    if (!qrData) return res.status(400).json({ message: 'QR data is required' });

    const result = await TicketService.verifyTicket(qrData, user);
    res.status(200).json(result);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
