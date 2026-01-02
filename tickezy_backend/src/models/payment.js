const { DataTypes } = require('sequelize');
const sequelize = require('../../db');

const Payment = sequelize.define('Payment', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  amount: {
    type: DataTypes.DOUBLE,
    allowNull: false,
  },
  paymentStatus: {
    type: DataTypes.ENUM('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED'),
    defaultValue: 'PENDING',
  },
  paymentMethod: {
    type: DataTypes.ENUM('STRIPE', 'APPLE_PAY', 'CREDIT_CARD', 'MOBILE_MONEY', 'PAYPAL', 'CASH'),
    defaultValue: 'CREDIT_CARD',
  },
  paymentDate: DataTypes.DATE,
  transactionId: DataTypes.STRING,
}, {
  timestamps: true,
});

module.exports = Payment;
