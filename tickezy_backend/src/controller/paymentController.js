const PaymentService = require('../services/paymentService');

/**
 * Create a new payment (authenticated user)
 */
exports.createPayment = async (req, res) => {
  try {
    const { eventId, ticketId, amount, paymentMethod, transactionId } = req.body;
    const userId = req.user.id; // authenticated user ID

    const payment = await PaymentService.createPayment({
      userId,
      eventId,
      ticketId,
      amount,
      paymentMethod,
      transactionId,
    });

    res.status(201).json({ message: 'Payment created successfully', payment });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

/**
 * Get all payments (admins see all, users see only their own)
 */
exports.getAllPayments = async (req, res) => {
  try {
    const user = req.user;
    const payments = await PaymentService.getAllPayments(user);
    res.status(200).json(payments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

/**
 * Get a single payment by ID (admins can access any, users only their own)
 */
exports.getPaymentById = async (req, res) => {
  try {
    const user = req.user;
    const payment = await PaymentService.getPaymentById(req.params.id, user);
    res.status(200).json(payment);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

/**
 * Update payment status (admin or staff only)
 */
exports.updatePaymentStatus = async (req, res) => {
  try {
    const user = req.user;
    const allowedRoles = ['ADMIN', 'STAFF'];

    if (!allowedRoles.includes(user.role?.toUpperCase())) {
      return res
        .status(403)
        .json({ message: 'Access denied: Only admin or staff can update payment status' });
    }

    const { status } = req.body;
    if (!status) return res.status(400).json({ message: 'Payment status is required' });

    const payment = await PaymentService.updatePaymentStatus(req.params.id, status);
    res.status(200).json({ message: 'Payment status updated successfully', payment });
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};

/**
 * Delete a payment (admin only)
 */
exports.deletePayment = async (req, res) => {
  try {
    const user = req.user;
    if (user.role?.toUpperCase() !== 'ADMIN') {
      return res.status(403).json({ message: 'Access denied: Admins only' });
    }

    const result = await PaymentService.deletePayment(req.params.id);
    res.status(200).json(result);
  } catch (error) {
    res.status(404).json({ message: error.message });
  }
};

/**
 * Filter payments by status or date range (admin only)
 */
exports.filterPayments = async (req, res) => {
  try {
    const user = req.user;
    if (user.role?.toUpperCase() !== 'ADMIN') {
      return res.status(403).json({ message: 'Access denied: Admins only' });
    }

    const { status, startDate, endDate } = req.query;

    const payments = await PaymentService.filterPayments({
      status,
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
    });

    res.status(200).json(payments);
  } catch (error) {
    res.status(400).json({ message: error.message });
  }
};
