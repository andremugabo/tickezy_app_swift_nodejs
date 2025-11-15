const jwt = require('jsonwebtoken');
const Joi = require('joi');
const bcrypt = require('bcrypt');
const { User, Notification } = require('../models');

/**
 * 🧩 Helper: Wrap async route handlers
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

/**
 * 📦 Validation Schemas
 */
const registerSchema = Joi.object({
  name: Joi.string().min(2).max(100).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  phoneNumber: Joi.string().optional(),
  role: Joi.string().valid('ADMIN', 'CUSTOMER').optional(),
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

/**
 * 🧩 Helper: Generate JWT Token
 */
const generateToken = (user) =>
  jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
  );

/**
 * 🧍 Register a New User
 */
exports.register = asyncHandler(async (req, res) => {
  const { error, value } = registerSchema.validate(req.body, { abortEarly: false });
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      details: error.details.map((d) => d.message),
    });
  }

  const { name, email, password, phoneNumber, role } = value;
  const normalizedEmail = email.trim().toLowerCase();

  const existingUser = await User.findOne({ where: { email: normalizedEmail } });
  if (existingUser) {
    return res.status(400).json({ success: false, message: 'Email already registered' });
  }

  const user = await User.create({
    name,
    email: normalizedEmail,
    password,
    phoneNumber,
    role: role || 'CUSTOMER',
  });

  const token = generateToken(user);

  res.status(201).json({
    success: true,
    message: 'User registered successfully',
    token,
    data: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
  });
});

/**
 * 🔐 Login Existing User
 */
exports.login = asyncHandler(async (req, res) => {
  const { error, value } = loginSchema.validate(req.body, { abortEarly: false });
  if (error) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      details: error.details.map((d) => d.message),
    });
  }

  const { email, password } = value;
  const normalizedEmail = email.trim().toLowerCase();

  const user = await User.findOne({ where: { email: normalizedEmail } });
  if (!user) throw new Error('Invalid email or password');

  const validPassword = await bcrypt.compare(password, user.password);
  if (!validPassword) throw new Error('Invalid email or password');

  user.lastLoginAt = new Date();
  await user.save();

  const token = generateToken(user);

  res.status(200).json({
    success: true,
    message: 'Login successful',
    token,
    data: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    },
  });
});

/**
 * 👤 Get Logged-in User Profile
 */
exports.getProfile = asyncHandler(async (req, res) => {
  const user = req.user;
  if (!user) throw new Error('User not found');

  res.status(200).json({
    success: true,
    data: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      phoneNumber: user.phoneNumber,
      createdAt: user.createdAt,
    },
  });
});

/**
 * 📝 Update Logged-in User Profile
 */
exports.updateProfile = asyncHandler(async (req, res) => {
  const { name, phoneNumber } = req.body;

  const user = await User.findByPk(req.user.id);
  if (!user) throw new Error('User not found');

  if (name) user.name = name;
  if (phoneNumber) user.phoneNumber = phoneNumber;

  await user.save();

  res.status(200).json({
    success: true,
    message: 'Profile updated successfully',
    data: user,
  });
});

/**
 * 🔔 Update FCM Device Token
 */
exports.updateFcmToken = asyncHandler(async (req, res) => {
  const { fcmToken } = req.body;
  if (!fcmToken) throw new Error('FCM token is required');

  const user = await User.findByPk(req.user.id);
  user.fcmToken = fcmToken;
  await user.save();

  res.status(200).json({ success: true, message: 'Device token updated successfully' });
});

/**
 * 👥 Get All Users (Admin)
 */
exports.getAllUsers = asyncHandler(async (req, res) => {
  const users = await User.findAll({ attributes: { exclude: ['password'] } });
  res.status(200).json({ success: true, data: users });
});

/**
 * 🔔 Get All Notifications
 */
exports.getNotifications = asyncHandler(async (req, res) => {
  const notifications = await Notification.findAll({
    where: { userId: req.user.id },
    order: [['createdAt', 'DESC']],
  });

  res.status(200).json({ success: true, data: notifications });
});

/**
 * ✅ Mark Single Notification as Read
 */
exports.markNotificationRead = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const notif = await Notification.findByPk(id);

  if (!notif || notif.userId !== req.user.id) throw new Error('Notification not found');

  notif.isRead = true;
  await notif.save();

  res.status(200).json({ success: true, message: 'Notification marked as read' });
});

/**
 * 🔔 Mark All Notifications as Read
 */
exports.markAllNotificationsRead = asyncHandler(async (req, res) => {
  await Notification.update({ isRead: true }, { where: { userId: req.user.id } });
  res.status(200).json({ success: true, message: 'All notifications marked as read' });
});

/**
 * 🗑️ Delete a Single Notification
 */
exports.deleteNotification = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const notif = await Notification.findByPk(id);

  if (!notif || notif.userId !== req.user.id) throw new Error('Notification not found');

  await notif.destroy();
  res.status(200).json({ success: true, message: 'Notification deleted' });
});

exports.sendNotificationToUser = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const { title, message, type, relatedEventId, relatedTicketId } = req.body;

  if (!title || !message) {
    return res.status(400).json({ success: false, message: 'Title and message are required' });
  }

  const user = await User.findByPk(id);
  if (!user) return res.status(404).json({ success: false, message: 'User not found' });

  const payload = {
    userId: user.id,
    title,
    message,
    type: type || 'ADMIN_MESSAGE',
    timestamp: new Date(),
    relatedEventId: relatedEventId || null,
    relatedTicketId: relatedTicketId || null,
  };
  const notif = await Notification.create(payload);

  res.status(201).json({ success: true, message: 'Notification sent', data: notif });
});
