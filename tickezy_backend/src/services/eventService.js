const { Event, User } = require('../models');
const { Op } = require('sequelize');
const fs = require('fs');
const path = require('path');

/**
 * Create a new event (admin only)
 */
const createEvent = async (eventData, adminId, imageFile) => {
  const admin = await User.findByPk(adminId);
  if (!admin || admin.role !== 'ADMIN') {
    throw new Error('Unauthorized: Only admins can create events');
  }

  // attach image URL if file uploaded
  if (imageFile) {
    eventData.imageURL = `/uploads/events/${imageFile.filename}`;
  }

  const event = await Event.create(eventData);
  return event;
};

/**
 * Update an existing event (admin only)
 */
const updateEvent = async (eventId, updates, adminId, imageFile) => {
  const admin = await User.findByPk(adminId);
  if (!admin || admin.role !== 'ADMIN') {
    throw new Error('Unauthorized: Only admins can update events');
  }

  const event = await Event.findByPk(eventId);
  if (!event) throw new Error('Event not found');

  // If new image uploaded → remove old one & set new
  if (imageFile) {
    if (event.imageURL) {
      const oldImagePath = path.join(__dirname, '../../', event.imageURL);
      if (fs.existsSync(oldImagePath)) fs.unlinkSync(oldImagePath);
    }
    updates.imageURL = `/uploads/events/${imageFile.filename}`;
  }

  await event.update(updates);
  return event;
};

/**
 * Get all events (with optional filters)
 */
/**
 * Get all events with optional filters, search, and pagination
 * @param {Object} filters - category, status, isPublished, search
 * @param {number} page - page number (default 1)
 * @param {number} limit - number of items per page (default 10)
 */
const getAllEvents = async (filters = {}, page = 1, limit = 10) => {
  const where = {};

  // Filter by category
  if (filters.category) where.category = filters.category;

  // Filter by status
  if (filters.status) where.status = filters.status;

  // Filter by isPublished (convert string to boolean)
  if (filters.isPublished !== undefined) {
    if (filters.isPublished === 'true') where.isPublished = true;
    else if (filters.isPublished === 'false') where.isPublished = false;
  }

  // Search by title (case-insensitive)
  if (filters.search) {
    where.title = { [Op.iLike]: `%${filters.search}%` }; // Use iLike for Postgres, Op.like for others
  }

  const offset = (page - 1) * limit;

  // Fetch events with pagination
  const { count, rows } = await Event.findAndCountAll({
    where,
    order: [['eventDate', 'ASC']],
    limit,
    offset,
  });

  return {
    events: rows,
    pagination: {
      total: count,
      page,
      limit,
      totalPages: Math.ceil(count / limit),
    },
  };
};


/**
 * Get a single event by ID
 */
const getEventById = async (id) => {
  const event = await Event.findByPk(id);
  if (!event) throw new Error('Event not found');
  return event;
};

/**
 * Delete an event (admin only)
 */
const deleteEvent = async (id, adminId) => {
  const admin = await User.findByPk(adminId);
  if (!admin || admin.role !== 'ADMIN') {
    throw new Error('Unauthorized: Only admins can delete events');
  }

  const event = await Event.findByPk(id);
  if (!event) throw new Error('Event not found');

  // delete image file if exists
  if (event.imageURL) {
    const imagePath = path.join(__dirname, '../../', event.imageURL);
    if (fs.existsSync(imagePath)) fs.unlinkSync(imagePath);
  }

  await event.destroy();
  return { message: 'Event deleted successfully' };
};

module.exports = {
  createEvent,
  updateEvent,
  getAllEvents,
  getEventById,
  deleteEvent,
};
