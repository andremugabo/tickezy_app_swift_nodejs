const User = require('./user');
const Event = require('./event');
const Ticket = require('./ticket');
const Payment = require('./payment');
const Notification = require('./notification');

// Relations

// User Relations
User.hasMany(Event, { foreignKey: 'createdBy', onDelete: 'CASCADE' });
Event.belongsTo(User, { foreignKey: 'createdBy' });

User.hasMany(Ticket, { foreignKey: 'userId', onDelete: 'CASCADE' });
Ticket.belongsTo(User, { foreignKey: 'userId' });

User.hasMany(Payment, { foreignKey: 'userId', onDelete: 'CASCADE' });
Payment.belongsTo(User, { foreignKey: 'userId' });

User.hasMany(Notification, { foreignKey: 'userId', onDelete: 'CASCADE' });
Notification.belongsTo(User, { foreignKey: 'userId' });

// Event Relations
Event.hasMany(Ticket, { foreignKey: 'eventId', onDelete: 'CASCADE' });
Ticket.belongsTo(Event, { foreignKey: 'eventId' });

Event.hasMany(Payment, { foreignKey: 'eventId', onDelete: 'CASCADE' });
Payment.belongsTo(Event, { foreignKey: 'eventId' });

// Ticket to Payment
Ticket.hasOne(Payment, { foreignKey: 'ticketId' });
Payment.belongsTo(Ticket, { foreignKey: 'ticketId' });

module.exports = {
  User,
  Event,
  Ticket,
  Payment,
  Notification
};
