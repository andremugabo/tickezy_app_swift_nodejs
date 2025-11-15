const { DataTypes } = require('sequelize');
const sequelize = require('../../db');
const bcrypt = require('bcrypt');

const User = sequelize.define('User', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  email: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true,
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  password: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  role: {
    type: DataTypes.ENUM('ADMIN', 'CUSTOMER', 'STAFF'),
    defaultValue: 'CUSTOMER',
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true,
  },
  resetOtp: {
    type: DataTypes.STRING,
    allowNull: true
  },
  resetOtpExpires: {
    type: DataTypes.DATE,
    allowNull: true
  },
  lastLoginAt: DataTypes.DATE,
  phoneNumber: DataTypes.STRING,
  // Optional profile fields
  fcmToken: DataTypes.STRING,
  profileImageURL: DataTypes.STRING,
}, {
  timestamps: true,
  hooks: {
    beforeCreate: async (user) => {
      if (user.password) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    },
    beforeUpdate: async (user) => {
      if (user.changed('password')) {
        const salt = await bcrypt.genSalt(10);
        user.password = await bcrypt.hash(user.password, salt);
      }
    },
  },
});

module.exports = User;
