const { Event, User } = require('../models');
const { Op } = require('sequelize');
const fs = require('fs');
const path = require('path');

/**
 * Create a new event (admin only)
 */
const createEvent = async (eventData, adminId) => {
  const admin = await User.findByPk(adminId);
  if (!admin || admin.role !== 'ADMIN') {
    throw new Error('Unauthorized: Only admins can create events');
  }

  const event = await Event.create(eventData);
  return event;
};

/**
 * Update an existing event (admin only)
 */
const updateEvent = async (eventId, updates, adminId) => {
  const admin = await User.findByPk(adminId);
  if (!admin || admin.role !== 'ADMIN') {
    throw new Error('Unauthorized: Only admins can update events');
  }

  const event = await Event.findByPk(eventId);
  if (!event) throw new Error('Event not found');

  // Delete old image if new one provided
  if (updates.imageURL && event.imageURL && event.imageURL !== updates.imageURL) {
    const oldImagePath = path.join(__dirname, '../../', event.imageURL);
    if (fs.existsSync(oldImagePath)) fs.unlinkSync(oldImagePath);
  }

  await event.update(updates);
  return event;
};

/**
 * Delete an event (admin only)
 */
const deleteEvent = async (eventId, adminId) => {
  const admin = await User.findByPk(adminId);
  if (!admin || admin.role !== 'ADMIN') {
    throw new Error('Unauthorized: Only admins can delete events');
  }

  const event = await Event.findByPk(eventId);
  if (!event) throw new Error('Event not found');

  if (event.imageURL) {
    const imgPath = path.join(__dirname, '../../', event.imageURL);
    if (fs.existsSync(imgPath)) {
      try { fs.unlinkSync(imgPath); } catch (_) {}
    }
  }

  await event.destroy();
  return { message: 'Event deleted successfully' };
};

/**
 * Get all events with optional filters, search, and pagination
 */
const getAllEvents = async (filters = {}, page = 1, limit = 10) => {
  const where = {};
  if (filters.category) where.category = filters.category;
  if (filters.status) where.status = filters.status;
  if (filters.isPublished !== undefined) {
    where.isPublished = filters.isPublished === 'true';
  }
  if (filters.search) {
    where.title = { [Op.iLike]: `%${filters.search}%` };
  }

  const offset = (page - 1) * limit;
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

module.exports = {
  createEvent,
  updateEvent,
  deleteEvent,
  getAllEvents,
  getEventById,
};
