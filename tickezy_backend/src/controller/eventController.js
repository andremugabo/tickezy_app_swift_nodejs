const eventService = require('../services/eventService');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');

/**
 * Helper to process uploaded image: resize + compress
 */
const processEventImage = async (file) => {
  if (!file) return null;

  const uploadDir = path.join(__dirname, '../../uploads/events');
  fs.mkdirSync(uploadDir, { recursive: true });

  const filename = `${Date.now()}-${file.originalname}`;
  const filepath = path.join(uploadDir, filename);

  await sharp(file.buffer)
    .resize(800)
    .jpeg({ quality: 80 })
    .toFile(filepath);

  return `/uploads/events/${filename}`;
};

/**
 * Create Event (Admin only)
 */
const createEvent = async (req, res) => {
  try {
    const adminId = req.user.id;
    const imageURL = await processEventImage(req.file);
    const eventData = { ...req.body };
    if (imageURL) eventData.imageURL = imageURL;

    const event = await eventService.createEvent(eventData, adminId);

    res.status(201).json({ success: true, message: 'Event created successfully', data: event });
  } catch (error) {
    console.error('Create Event Error:', error);
    res.status(400).json({ success: false, message: error.message });
  }
};

/**
 * Update Event (Admin only)
 */
const updateEvent = async (req, res) => {
  try {
    const adminId = req.user.id;
    const eventId = req.params.id;

    const imageURL = await processEventImage(req.file);
    const updates = { ...req.body };
    if (imageURL) updates.imageURL = imageURL;

    const updatedEvent = await eventService.updateEvent(eventId, updates, adminId);

    res.status(200).json({ success: true, message: 'Event updated successfully', data: updatedEvent });
  } catch (error) {
    console.error('Update Event Error:', error);
    res.status(400).json({ success: false, message: error.message });
  }
};

/**
 * Delete Event (Admin only)
 */
const deleteEvent = async (req, res) => {
  try {
    const adminId = req.user.id;
    const eventId = req.params.id;
    await eventService.deleteEvent(eventId, adminId);
    res.status(200).json({ success: true, message: 'Event deleted successfully' });
  } catch (error) {
    console.error('Delete Event Error:', error);
    res.status(400).json({ success: false, message: error.message });
  }
};

/**
 * Get all events (public)
 */
const getAllEvents = async (req, res) => {
  try {
    const { page = 1, limit = 10, category, status, isPublished, search } = req.query;
    const filters = { category, status, isPublished, search };
    const pageNum = parseInt(page, 10);
    const limitNum = parseInt(limit, 10);

    const result = await eventService.getAllEvents(filters, pageNum, limitNum);

    res.status(200).json({
      success: true,
      data: result.events,
      pagination: result.pagination,
    });
  } catch (error) {
    console.error('Get All Events Error:', error);
    res.status(400).json({ success: false, message: error.message });
  }
};

/**
 * Get single event by ID (public)
 */
const getEventById = async (req, res) => {
  try {
    const event = await eventService.getEventById(req.params.id);
    res.status(200).json({ success: true, data: event });
  } catch (error) {
    console.error('Get Event Error:', error);
    res.status(404).json({ success: false, message: error.message });
  }
};

module.exports = {
  createEvent,
  updateEvent,
  deleteEvent,
  getAllEvents,
  getEventById,
};
