const TicketService = require('../services/ticketService');
const { Event, Ticket, Payment } = require('../models');
const QRCode = require('qrcode');

/**
 * Create a new ticket (any authenticated user)
 */
exports.createTicket = async (req, res) => {
  try {
    const { eventId, quantity, paymentMethod } = req.body;
    const userId = req.user.id;

    // 1. Fetch Event
    const event = await Event.findByPk(eventId);
    if (!event) {
      return res.status(404).json({ message: 'Event not found' });
    }

    // 2. Check Availability
    if (event.ticketsSold + quantity > event.totalTickets) {
      return res.status(400).json({ message: 'Not enough tickets available' });
    }

    // 3. Create Tickets
    const tickets = [];
    for (let i = 0; i < quantity; i++) {
      const uniqueId = `${eventId}-${userId}-${Date.now()}-${i}`;
      const qrData = `event:${eventId}|ticket:${uniqueId}`;
      const qrCodeURL = await QRCode.toDataURL(qrData);

      if (!qrCodeURL) {
        throw new Error('Failed to generate QR Code');
      }

      console.log('Generated QR Code Length:', qrCodeURL.length);

      const ticket = await Ticket.create({
        userId,
        eventId,
        quantity: 1,
        status: 'VALID',
        qrCodeURL,
        purchaseDate: new Date()
      });
      tickets.push(ticket);

      // 4. Create Payment 
      await Payment.create({
        userId,
        eventId,
        ticketId: ticket.id,
        amount: event.price,
        paymentMethod: paymentMethod || 'CREDIT_CARD',
        paymentStatus: 'SUCCESS',
        paymentDate: new Date(),
        transactionId: `TXN-${Date.now()}-${i}`
      });
    }

    // 5. Update Event Sales
    await event.increment('ticketsSold', { by: quantity });

    res.status(201).json({
      message: 'Tickets purchased successfully',
      tickets
    });

  } catch (error) {
    console.error("Purchase Error:", error);
    res.status(400).json({ message: error.message });
  }
};

/**
 * Get all tickets (admins see all, users see only their tickets)
 */
exports.getAllTickets = async (req, res) => {
  try {
    const user = req.user;
    const { userId } = req.query;
    const tickets = await TicketService.getAllTickets(user, userId);
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
