const { DataTypes } = require('sequelize');
const sequelize = require('../../db');

const Ticket = sequelize.define('Ticket', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  purchaseDate: DataTypes.DATE,
  quantity: {
    type: DataTypes.INTEGER,
    defaultValue: 1,
  },
  qrCodeURL: DataTypes.TEXT,
  status: {
    type: DataTypes.ENUM('VALID', 'USED', 'CANCELLED', 'REFUNDED'),
    defaultValue: 'VALID',
  },
  usedAt: DataTypes.DATE,
  checkedInBy: DataTypes.STRING,
}, {
  timestamps: true,
});

module.exports = Ticket;
