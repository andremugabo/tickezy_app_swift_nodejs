const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { User, Notification } = require('../models');
const { sendEmail } = require('../utils/emailService');

const generateToken = (user) => 
  jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
  );

const normalizeEmail = (email) => email.trim().toLowerCase();

class UserService {
  static async register({ name, email, password, phoneNumber, role }) {
    const normalizedEmail = normalizeEmail(email);

    const existingUser = await User.findOne({ where: { email: normalizedEmail } });
    if (existingUser) throw new Error('Email already registered');

    const user = await User.create({
      name,
      email: normalizedEmail,
      password,
      phoneNumber,
      role: role || 'CUSTOMER',
    });

    const token = generateToken(user);
    return { user, token };
  }

  static async login({ email, password }) {
    const normalizedEmail = normalizeEmail(email);
    const user = await User.findOne({ where: { email: normalizedEmail } });

    if (!user) throw new Error('Invalid email or password');

    const isValid = await bcrypt.compare(password, user.password);
    if (!isValid) throw new Error('Invalid email or password');

    user.lastLoginAt = new Date();
    await user.save();

    const token = generateToken(user);
    return { user, token };
  }

  static async sendPasswordOtp(email) {
    const normalizedEmail = normalizeEmail(email);
    const user = await User.findOne({ where: { email: normalizedEmail } });
    if (!user) throw new Error('Email not found');

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const hashedOtp = await bcrypt.hash(otp, 10);

    user.resetOtp = hashedOtp;
    user.resetOtpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 min
    await user.save();

    try {
      await sendEmail(
        user.email,
        'Tickezy Password Reset OTP',
        `<h2>Your OTP Code</h2>
        <p>Your password reset OTP is:</p>
        <h1>${otp}</h1>
        <p>This code will expire in <b>10 minutes</b>.</p>`
      );
    } catch (err) {
      throw new Error(`Failed to send OTP email: ${err?.message || err}`);
    }

    return true;
  }

  static async verifyOtp(email, otp) {
    const normalizedEmail = normalizeEmail(email);
    const user = await User.findOne({ where: { email: normalizedEmail } });
    if (!user) throw new Error('Email not found');
    if (!user.resetOtp || !user.resetOtpExpires) throw new Error('No active OTP request');
    if (user.resetOtpExpires < new Date()) throw new Error('OTP expired');

    const isValid = await bcrypt.compare(otp, user.resetOtp);
    if (!isValid) throw new Error('Invalid OTP');

    return true;
  }

  static async resetPassword(email, newPassword) {
    const normalizedEmail = normalizeEmail(email);
    const user = await User.findOne({ where: { email: normalizedEmail } });
    if (!user) throw new Error('Email not found');
    if (!user.resetOtp) throw new Error('OTP not verified');

    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(newPassword, salt);

    user.resetOtp = null;
    user.resetOtpExpires = null;
    await user.save();

    return true;
  }

  static async getProfile(userId) {
    const user = await User.findByPk(userId);
    if (!user) throw new Error('User not found');
    return user;
  }

  static async updateProfile(userId, updates) {
    const user = await User.findByPk(userId);
    if (!user) throw new Error('User not found');

    if (updates.name) user.name = updates.name;
    if (updates.phoneNumber) user.phoneNumber = updates.phoneNumber;

    await user.save();
    return user;
  }

  static async updateFcmToken(userId, fcmToken) {
    if (!fcmToken) throw new Error('FCM token is required');

    const user = await User.findByPk(userId);
    if (!user) throw new Error('User not found');

    user.fcmToken = fcmToken;
    await user.save();
    return true;
  }

  static async getAllUsers() {
    const users = await User.findAll({ attributes: { exclude: ['password'] } });
    return users;
  }

  static async getNotifications(userId) {
    const notifications = await Notification.findAll({
      where: { userId },
      order: [['createdAt', 'DESC']],
    });
    return notifications;
  }

  static async markNotificationRead(userId, notifId) {
    const notif = await Notification.findByPk(notifId);
    if (!notif || notif.userId !== userId) throw new Error('Notification not found');

    notif.isRead = true;
    await notif.save();
    return notif;
  }

  static async markAllNotificationsRead(userId) {
    await Notification.update({ isRead: true }, { where: { userId } });
    return true;
  }

  static async deleteNotification(userId, notifId) {
    const notif = await Notification.findByPk(notifId);
    if (!notif || notif.userId !== userId) throw new Error('Notification not found');

    await notif.destroy();
    return true;
  }

  static async sendNotificationToUser(userId, payload) {
    const { title, message, type, relatedEventId, relatedTicketId } = payload;
    if (!title || !message) throw new Error('Title and message are required');

    const user = await User.findByPk(userId);
    if (!user) throw new Error('User not found');

    const notif = await Notification.create({
      userId,
      title,
      message,
      type: type || 'ADMIN_MESSAGE',
      relatedEventId: relatedEventId || null,
      relatedTicketId: relatedTicketId || null,
    });

    return notif;
  }
}

module.exports = UserService;
