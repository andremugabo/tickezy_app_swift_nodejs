const { Ticket, Event, User, Notification } = require('../models');
const { v4: uuidv4 } = require('uuid');
const QRCode = require('qrcode');

/**
 * Create a new ticket
 * @param {Object} param0 - ticket data
 * @param {string} param0.userId - ID of the user purchasing the ticket
 * @param {string} param0.eventId - ID of the event
 * @param {number} param0.quantity - Number of tickets
 * @param {string} [param0.checkedInBy] - Optional check-in user
 */
async function createTicket({ userId, eventId, quantity = 1, checkedInBy }) {
  const event = await Event.findByPk(eventId);
  if (!event) throw new Error('Event not found');

  if (event.ticketsSold + quantity > event.totalTickets) {
    throw new Error('Not enough tickets available');
  }

  const qrData = `event:${eventId}|ticket:${uuidv4()}`;
  const qrCodeURL = await QRCode.toDataURL(qrData);

  const ticket = await Ticket.create({
    id: uuidv4(),
    userId, // assign ownership
    eventId,
    quantity,
    purchaseDate: new Date(),
    qrCodeURL,
    checkedInBy: checkedInBy || null,
  });

  event.ticketsSold += quantity;
  await event.save();

  // Create notification for user
  try {
    await Notification.create({
      userId,
      title: 'Ticket Confirmed! 🎉',
      message: `Your purchase for ${event.title} was successful. You have ${quantity} ticket(s) ready!`,
      type: 'TICKET_CONFIRMATION',
      timestamp: new Date(),
      relatedEventId: eventId,
      relatedTicketId: ticket.id,
    });
  } catch (_) { }

  return ticket;
}

/**
 * Get all tickets
 * @param {Object} user - authenticated user object
 */
async function getAllTickets(user, userIdFilter) {
  const query = { include: [Event, User] };

  if (user.role?.toUpperCase() !== 'ADMIN') {
    query.where = { userId: user.id };
  } else if (userIdFilter) {
    query.where = { userId: userIdFilter };
  }

  return await Ticket.findAll(query);
}

/**
 * Get a single ticket
 * @param {string} id - ticket ID
 * @param {Object} user - authenticated user
 */
async function getTicketById(id, user) {
  const ticket = await Ticket.findByPk(id, { include: [Event, User] });
  if (!ticket) throw new Error('Ticket not found');

  if (user.role?.toUpperCase() !== 'ADMIN' && ticket.userId !== user.id) {
    throw new Error('Access denied');
  }

  return ticket;
}

/**
 * Update ticket status (admin or staff only)
 * @param {string} id - ticket ID
 * @param {string} status - new status
 * @param {Object} user - authenticated user performing update
 */
async function updateTicketStatus(id, status, user) {
  const ticket = await Ticket.findByPk(id);
  if (!ticket) throw new Error('Ticket not found');

  const allowedRoles = ['ADMIN', 'STAFF'];
  if (!allowedRoles.includes(user.role?.toUpperCase())) {
    throw new Error('Access denied: Only admin or staff can update ticket status');
  }

  await ticket.update({
    status,
    usedAt: status === 'USED' ? new Date() : null,
  });

  return ticket;
}

/**
 * Delete a ticket (admin only)
 * @param {string} id - ticket ID
 */
async function deleteTicket(id) {
  const ticket = await Ticket.findByPk(id);
  if (!ticket) throw new Error('Ticket not found');

  const event = await Event.findByPk(ticket.eventId);
  if (event && event.ticketsSold >= ticket.quantity) {
    event.ticketsSold -= ticket.quantity;
    await event.save();
  }

  await ticket.destroy();
  return { message: 'Ticket deleted successfully' };
}


/**
 * Verify QR code data
 * @param {string} qrData - Raw QR code data string
 * @param {Object} user - Authenticated staff user performing the scan
 */
async function verifyTicket(qrData, user) {
  // Example QR data format: "event:1234|ticket:abcd"
  const match = qrData.match(/event:([^|]+)\|ticket:([^|]+)/);
  if (!match) throw new Error('Invalid QR format');

  const [, eventId, ticketId] = match;

  const ticket = await Ticket.findOne({
    where: { id: ticketId, eventId },
    include: [Event, User],
  });

  if (!ticket) throw new Error('Ticket not found');
  if (ticket.status === 'USED') throw new Error('Ticket already used');
  if (ticket.status === 'CANCELLED' || ticket.status === 'REFUNDED')
    throw new Error(`Ticket is ${ticket.status.toLowerCase()}`);

  // ✅ Mark ticket as used
  await ticket.update({
    status: 'USED',
    usedAt: new Date(),
    checkedInBy: user.id || user.username,
  });

  return {
    message: 'Ticket verified successfully',
    event: ticket.Event.title,
    user: ticket.User.name,
    usedAt: ticket.usedAt,
  };
}

module.exports = {
  createTicket,
  getAllTickets,
  getTicketById,
  updateTicketStatus,
  deleteTicket,
  verifyTicket,
};
