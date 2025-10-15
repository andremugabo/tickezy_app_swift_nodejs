const express = require('express');
const router = express.Router();
const eventController = require('../controller/eventController');
const { authenticate } = require('../middleware/authMiddleware');
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');

// Ensure uploads directory exists
const uploadDir = path.join(__dirname, '../../uploads/events');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Multer memory storage for processing with Sharp
const storage = multer.memoryStorage();
const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|webp/;
  const mimeType = allowedTypes.test(file.mimetype);
  const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  if (mimeType && extname) cb(null, true);
  else cb(new Error('Only image files (jpg, jpeg, png, webp) are allowed!'));
};
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
  fileFilter,
});

// Middleware to resize/compress event image
const resizeEventImage = async (req, res, next) => {
  if (!req.file) return next();

  try {
    const filename = `${Date.now()}-${req.file.originalname}`;
    const filepath = path.join(uploadDir, filename);

    await sharp(req.file.buffer)
      .resize(800)          // width 800px, auto height
      .jpeg({ quality: 80 }) // compress JPEG
      .toFile(filepath);

    req.file.filename = filename; // pass filename to controller
    next();
  } catch (error) {
    next(error);
  }
};

// ===================
// Event Routes
// ===================

// Create event (Admin only)
router.post('/', authenticate, upload.single('image'), resizeEventImage, eventController.createEvent);

// Update event (Admin only)
router.put('/:id', authenticate, upload.single('image'), resizeEventImage, eventController.updateEvent);

// Get all events (Public)
router.get('/', eventController.getAllEvents);

// Get event by ID (Public)
router.get('/:id', eventController.getEventById);

// Delete event (Admin only)
router.delete('/:id', authenticate, eventController.deleteEvent);

module.exports = router;
