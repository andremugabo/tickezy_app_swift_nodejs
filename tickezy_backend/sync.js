const sequelize = require('./db');
const { User, Event, Ticket, Payment, Notification } = require('./src/models');

async function syncDatabase() {
  try {
    await sequelize.authenticate();
    console.log('Database connected successfully.');

    // Sync all models
    await sequelize.sync({ force: true }); 
    console.log('All models were synchronized successfully.');

    // Seed initial data
    await seedData();

    process.exit(0);
  } catch (error) {
    console.error('Unable to connect to the database:', error);
  }
}

async function seedData() {
    // Create an admin user
    const admin = await User.create({
      email: 'admin@tickezy.com',
      name: 'Admin User',
      role: 'ADMIN',
      phoneNumber: '+250000000000',
      password: '123456',
    });
    console.log('Seeded admin user:', admin.email);
  
    // Create a sample customer user
    const customer = await User.create({
      email: 'customer@tickezy.com',
      name: 'Customer  user',
      role: 'CUSTOMER',
      phoneNumber: '+2500111222333',
      password: '123456',
    });
    console.log('Seeded customer user:', customer.email);
  
    // Create a sample event
    const event = await Event.create({
      title: 'Sample Concert',
      description: 'This is a sample concert event.',
      location: 'Kigali Arena',
      eventDate: new Date(),
      price: 50,
      totalTickets: 100,
      createdBy: admin.id,
      category: 'CONCERT',
      status: 'UPCOMING',
    });
    console.log('Seeded event:', event.title);
  
    // Create a ticket for the customer
    const ticket = await Ticket.create({
      userId: customer.id,
      eventId: event.id,
      purchaseDate: new Date(),
      quantity: 2,
      status: 'VALID',
    });
    console.log('Seeded ticket for customer:', customer.email);
  
    // Create a payment linked to the ticket
    const payment = await Payment.create({
      userId: customer.id,
      ticketId: ticket.id,
      eventId: event.id,
      amount: event.price * ticket.quantity,
      paymentStatus: 'SUCCESS',
      paymentMethod: 'STRIPE',
      paymentDate: new Date(),
      transactionId: `TXN-${Date.now()}`,
    });
    console.log('Seeded payment for ticket:', payment.transactionId);
  
    // Create a notification for the customer
    const notification = await Notification.create({
      userId: customer.id,
      title: 'Ticket Confirmed',
      message: `Your ticket for ${event.title} has been confirmed.`,
      type: 'TICKET_CONFIRMATION',
      timestamp: new Date(),
      isRead: false,
      relatedEventId: event.id,
      relatedTicketId: ticket.id,
    });
    console.log('Seeded notification for customer:', notification.title);
  }
  

syncDatabase();
