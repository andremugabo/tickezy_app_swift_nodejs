const TicketService = require('../services/ticketService');

exports.createTicket = async (req, res) => {
  try {
    const { eventId, quantity, checkedInBy } = req.body;
    const ticket = await TicketService.createTicket({ eventId, quantity, checkedInBy });
    res.status(201).json({ message: 'Ticket created successfully', ticket });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.getAllTickets = async (req, res) => {
  try {
    const tickets = await TicketService.getAllTickets();
    res.status(200).json(tickets);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

exports.getTicketById = async (req, res) => {
  try {
    const ticket = await TicketService.getTicketById(req.params.id);
    res.status(200).json(ticket);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

exports.updateTicketStatus = async (req, res) => {
  try {
    const ticket = await TicketService.updateTicketStatus(req.params.id, req.body.status);
    res.status(200).json({ message: 'Ticket status updated', ticket });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

exports.deleteTicket = async (req, res) => {
  try {
    const result = await TicketService.deleteTicket(req.params.id);
    res.status(200).json(result);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};
