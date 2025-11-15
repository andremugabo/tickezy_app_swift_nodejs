const { DataTypes } = require('sequelize');
const sequelize = require('../../db');

const Notification = sequelize.define('Notification', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  title: DataTypes.STRING,
  message: DataTypes.TEXT,
  type: {
    type: DataTypes.ENUM('TICKET_CONFIRMATION', 'EVENT_REMINDER', 'PAYMENT_SUCCESS', 'EVENT_UPDATE', 'ADMIN_MESSAGE'),
  },
  timestamp: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  isRead: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  relatedEventId: DataTypes.UUID,
  relatedTicketId: DataTypes.UUID,
}, {
  timestamps: true,
});

module.exports = Notification;
