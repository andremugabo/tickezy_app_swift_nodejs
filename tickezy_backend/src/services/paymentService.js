/**
 * paymentService.js
 * TICKEZY
 *
 * Handles all payment-related operations.
 * Fully compatible with Stripe, Apple Pay, or any custom payment processor.
 */

const { Payment, Ticket, User, Event } = require('../models');
const { v4: uuidv4 } = require('uuid');
const { Op } = require('sequelize');

/**
 * Generate a unique, human-readable transaction ID
 * Example: TXN-20251104-ABCD1234
 */
function generateTransactionId() {
  const date = new Date().toISOString().slice(0, 10).replace(/-/g, '');
  const random = Math.random().toString(36).substring(2, 10).toUpperCase();
  return `TXN-${date}-${random}`;
}

/**
 * Create a new payment record
 * @param {Object} param0
 * @param {string} param0.userId - User making the payment
 * @param {string} param0.eventId - Event being paid for
 * @param {string} param0.ticketId - Associated ticket ID
 * @param {number} param0.amount - Total amount
 * @param {string} param0.paymentMethod - Payment method (STRIPE, APPLE_PAY)
 * @param {string} [param0.transactionId] - External transaction reference
 */
async function createPayment({
  userId,
  eventId,
  ticketId,
  amount,
  paymentMethod,
  transactionId,
}) {
  const user = await User.findByPk(userId);
  if (!user) throw new Error('User not found');

  const event = await Event.findByPk(eventId);
  if (!event) throw new Error('Event not found');

  const ticket = await Ticket.findByPk(ticketId);
  if (!ticket) throw new Error('Ticket not found');

  // Generate transaction ID if not provided
  const generatedTransactionId = transactionId || generateTransactionId();

  // Create payment record
  const payment = await Payment.create({
    id: uuidv4(),
    userId,
    eventId,
    ticketId,
    amount,
    paymentMethod,
    transactionId: generatedTransactionId,
    paymentStatus: 'PENDING',
    paymentDate: new Date(),
  });

  return payment;
}

/**
 * Update payment status
 * @param {string} paymentId - Payment record ID
 * @param {string} status - New status (PENDING, SUCCESS, FAILED, REFUNDED)
 */
async function updatePaymentStatus(paymentId, status) {
  const payment = await Payment.findByPk(paymentId, { include: [User, Ticket, Event] });
  if (!payment) throw new Error('Payment not found');

  // Validate status
  const validStatuses = ['PENDING', 'SUCCESS', 'FAILED', 'REFUNDED'];
  if (!validStatuses.includes(status.toUpperCase())) {
    throw new Error('Invalid payment status');
  }

  payment.paymentStatus = status.toUpperCase();
  if (status.toUpperCase() === 'SUCCESS' && !payment.paymentDate) {
    payment.paymentDate = new Date();
  }

  await payment.save();

  // Optional: Sync ticket state on success/refund
  if (status.toUpperCase() === 'SUCCESS') {
    await Ticket.update(
      { status: 'VALID' },
      { where: { id: payment.ticketId } }
    );
  } else if (status.toUpperCase() === 'REFUNDED') {
    await Ticket.update(
      { status: 'REFUNDED' },
      { where: { id: payment.ticketId } }
    );
  }

  return payment;
}

/**
 * Get all payments (admin or per user)
 * @param {Object} user - Authenticated user
 */
async function getAllPayments(user) {
  const query = {
    include: [User, Event, Ticket],
    order: [['createdAt', 'DESC']],
  };

  if (user.role?.toUpperCase() !== 'ADMIN') {
    query.where = { userId: user.id };
  }

  return await Payment.findAll(query);
}

/**
 * Get a single payment record by ID
 * @param {string} id - Payment ID
 * @param {Object} user - Authenticated user
 */
async function getPaymentById(id, user) {
  const payment = await Payment.findByPk(id, { include: [User, Event, Ticket] });
  if (!payment) throw new Error('Payment not found');

  if (user.role?.toUpperCase() !== 'ADMIN' && payment.userId !== user.id) {
    throw new Error('Access denied');
  }

  return payment;
}

/**
 * Delete a payment (admin only)
 * @param {string} id - Payment ID
 */
async function deletePayment(id) {
  const payment = await Payment.findByPk(id);
  if (!payment) throw new Error('Payment not found');

  await payment.destroy();
  return { message: 'Payment deleted successfully' };
}

/**
 * Find payments by status or date range (for analytics/admin dashboards)
 * @param {Object} filters
 * @param {string} [filters.status]
 * @param {Date} [filters.startDate]
 * @param {Date} [filters.endDate]
 */
async function filterPayments({ status, startDate, endDate }) {
  const where = {};

  if (status) where.paymentStatus = status.toUpperCase();
  if (startDate && endDate) {
    where.paymentDate = { [Op.between]: [startDate, endDate] };
  }

  return await Payment.findAll({
    where,
    include: [User, Event],
    order: [['paymentDate', 'DESC']],
  });
}

module.exports = {
  createPayment,
  updatePaymentStatus,
  getAllPayments,
  getPaymentById,
  deletePayment,
  filterPayments,
};
