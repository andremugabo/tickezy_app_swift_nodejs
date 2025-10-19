const { Ticket, Event } = require('../models');
const { v4: uuidv4 } = require('uuid');
const QRCode = require('qrcode');

// Create a new ticket
async function createTicket({ eventId, quantity = 1, checkedInBy }) {
  const event = await Event.findByPk(eventId);
  if (!event) throw new Error('Event not found');

  if (event.ticketsSold + quantity > event.totalTickets) {
    throw new Error('Not enough tickets available');
  }

  const qrData = `event:${eventId}|ticket:${uuidv4()}`;
  const qrCodeURL = await QRCode.toDataURL(qrData);

  const ticket = await Ticket.create({
    id: uuidv4(),
    eventId,
    quantity,
    purchaseDate: new Date(),
    qrCodeURL,
    checkedInBy: checkedInBy || null,
  });

  event.ticketsSold += quantity;
  await event.save();

  return ticket;
}

// Get all tickets
async function getAllTickets() {
  return await Ticket.findAll({ include: [Event] });
}

// Get a single ticket
async function getTicketById(id) {
  const ticket = await Ticket.findByPk(id, { include: [Event] });
  if (!ticket) throw new Error('Ticket not found');
  return ticket;
}

// Update ticket status
async function updateTicketStatus(id, status) {
  const ticket = await Ticket.findByPk(id);
  if (!ticket) throw new Error('Ticket not found');

  await ticket.update({
    status,
    usedAt: status === 'USED' ? new Date() : null,
  });

  return ticket;
}

// Delete a ticket
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

module.exports = {
  createTicket,
  getAllTickets,
  getTicketById,
  updateTicketStatus,
  deleteTicket,
};
