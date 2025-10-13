const { DataTypes } = require('sequelize');
const sequelize = require('../../db');

const Event = sequelize.define('Event', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  description: DataTypes.TEXT,
  location: DataTypes.STRING,
  eventDate: DataTypes.DATE,
  price: DataTypes.DOUBLE,
  totalTickets: DataTypes.INTEGER,
  ticketsSold: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
  },
  imageURL: DataTypes.STRING,
  isPublished: {
    type: DataTypes.BOOLEAN,
    defaultValue: false,
  },
  category: {
    type: DataTypes.ENUM('CONCERT', 'SPORTS', 'CONFERENCE', 'THEATER', 'OTHER'),
    defaultValue: 'OTHER',
  },
  status: {
    type: DataTypes.ENUM('UPCOMING', 'ONGOING', 'COMPLETED', 'CANCELLED'),
    defaultValue: 'UPCOMING',
  },
}, {
  timestamps: true,
});

module.exports = Event;
