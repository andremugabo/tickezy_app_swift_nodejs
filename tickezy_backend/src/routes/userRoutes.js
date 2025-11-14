const express = require('express');
const router = express.Router();

const userController = require('../controller/userController');
const { authenticate, adminOnly } = require('../middleware/authMiddleware');

// -------------------------------------------
// 🔓 Public Routes
// -------------------------------------------
router.post('/register', userController.register);
router.post('/login', userController.login);

// -------------------------------------------
// 🔐 Protected Routes (User must be logged in)
// -------------------------------------------
router.get('/profile', authenticate, userController.getProfile);
router.put('/profile', authenticate, userController.updateProfile);
router.put('/device-token', authenticate, userController.updateFcmToken);

// -------------------------------------------
// 🔔 Notifications
// -------------------------------------------
router.get('/notifications', authenticate, userController.getNotifications);
router.put('/notifications/:id/read', authenticate, userController.markNotificationRead);
router.put('/notifications/read-all', authenticate, userController.markAllNotificationsRead);
router.delete('/notifications/:id', authenticate, userController.deleteNotification);

// -------------------------------------------
// 🛂 Admin Routes
// -------------------------------------------
router.get('/all', authenticate, adminOnly, userController.getAllUsers);

module.exports = router;
