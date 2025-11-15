const Joi = require('joi');
const UserService = require('../services/userService');

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
  role: Joi.string().valid('ADMIN', 'CUSTOMER', 'STAFF').optional(),
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

const sendOtpSchema = Joi.object({
  email: Joi.string().email().required(),
});

const verifyOtpSchema = Joi.object({
  email: Joi.string().email().required(),
  otp: Joi.string().length(6).required(),
});

const resetPasswordSchema = Joi.object({
  email: Joi.string().email().required(),
  newPassword: Joi.string().min(6).required(),
});

const updateProfileSchema = Joi.object({
  name: Joi.string().min(2).max(100).optional(),
  phoneNumber: Joi.string().optional(),
});

const sendNotificationSchema = Joi.object({
  title: Joi.string().required(),
  message: Joi.string().required(),
  type: Joi.string().optional(),
  relatedEventId: Joi.string().optional(),
  relatedTicketId: Joi.string().optional(),
});

/**
 * 🧍 Register
 */
exports.register = asyncHandler(async (req, res) => {
  const { error, value } = registerSchema.validate(req.body, { abortEarly: false });
  if (error) return res.status(400).json({ success: false, message: 'Validation failed', details: error.details });

  const { user, token } = await UserService.register(value);

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
 * 🔐 Login
 */
exports.login = asyncHandler(async (req, res) => {
  const { error, value } = loginSchema.validate(req.body, { abortEarly: false });
  if (error) return res.status(400).json({ success: false, message: 'Validation failed', details: error.details });

  const { user, token } = await UserService.login(value);

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
 * ======================
 * 🔵 PASSWORD RESET
 * ======================
 */
exports.sendPasswordOtp = asyncHandler(async (req, res) => {
  const { error, value } = sendOtpSchema.validate(req.body);
  if (error) return res.status(400).json({ success: false, message: error.details[0].message });

  await UserService.sendPasswordOtp(value.email);
  res.status(200).json({ success: true, message: 'OTP sent to email' });
});

exports.verifyOtp = asyncHandler(async (req, res) => {
  const { error, value } = verifyOtpSchema.validate(req.body);
  if (error) return res.status(400).json({ success: false, message: error.details[0].message });

  await UserService.verifyOtp(value.email, value.otp);
  res.status(200).json({ success: true, message: 'OTP verified successfully' });
});

exports.resetPassword = asyncHandler(async (req, res) => {
  const { error, value } = resetPasswordSchema.validate(req.body);
  if (error) return res.status(400).json({ success: false, message: error.details[0].message });

  await UserService.resetPassword(value.email, value.newPassword);
  res.status(200).json({ success: true, message: 'Password reset successfully' });
});

/**
 * 👤 Profile
 */
exports.getProfile = asyncHandler(async (req, res) => {
  const user = await UserService.getProfile(req.user.id);
  res.status(200).json({ success: true, data: user });
});

exports.updateProfile = asyncHandler(async (req, res) => {
  const { error, value } = updateProfileSchema.validate(req.body);
  if (error) return res.status(400).json({ success: false, message: error.details[0].message });

  const user = await UserService.updateProfile(req.user.id, value);
  res.status(200).json({ success: true, message: 'Profile updated successfully', data: user });
});

/**
 * 🔔 FCM Token
 */
exports.updateFcmToken = asyncHandler(async (req, res) => {
  const { fcmToken } = req.body;
  await UserService.updateFcmToken(req.user.id, fcmToken);
  res.status(200).json({ success: true, message: 'Device token updated successfully' });
});

/**
 * 👥 Admin: Users
 */
exports.getAllUsers = asyncHandler(async (req, res) => {
  const users = await UserService.getAllUsers();
  res.status(200).json({ success: true, data: users });
});

/**
 * 🔔 Notifications
 */
exports.getNotifications = asyncHandler(async (req, res) => {
  const notifications = await UserService.getNotifications(req.user.id);
  res.status(200).json({ success: true, data: notifications });
});

exports.markNotificationRead = asyncHandler(async (req, res) => {
  const notif = await UserService.markNotificationRead(req.user.id, req.params.id);
  res.status(200).json({ success: true, message: 'Notification marked as read', data: notif });
});

exports.markAllNotificationsRead = asyncHandler(async (req, res) => {
  await UserService.markAllNotificationsRead(req.user.id);
  res.status(200).json({ success: true, message: 'All notifications marked as read' });
});

exports.deleteNotification = asyncHandler(async (req, res) => {
  await UserService.deleteNotification(req.user.id, req.params.id);
  res.status(200).json({ success: true, message: 'Notification deleted' });
});

exports.sendNotificationToUser = asyncHandler(async (req, res) => {
  const { error, value } = sendNotificationSchema.validate(req.body);
  if (error) return res.status(400).json({ success: false, message: error.details[0].message });

  const notif = await UserService.sendNotificationToUser(req.params.id, value);
  res.status(201).json({ success: true, message: 'Notification sent', data: notif });
});
