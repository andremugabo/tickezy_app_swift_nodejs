const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');

// Multer memory storage for processing
const storage = multer.memoryStorage();
const fileFilter = (req, file, cb) => {
  const allowed = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'];
  if (allowed.includes(file.mimetype)) cb(null, true);
  else cb(new Error('Invalid image format. Allowed: JPG, PNG, WEBP'), false);
};

const uploadEventImage = multer({ storage, fileFilter });

// Middleware to resize/compress image
const resizeEventImage = async (req, res, next) => {
  if (!req.file) return next();

  try {
    const uploadDir = path.join(__dirname, '../../uploads/events');
    fs.mkdirSync(uploadDir, { recursive: true });

    const timestamp = Date.now();
    const ext = path.extname(req.file.originalname); // keep original extension
    const filename = `${timestamp}-${req.file.fieldname}${ext}`;
    const filepath = path.join(uploadDir, filename);

    // Determine the format for sharp
    const format = req.file.mimetype.split('/')[1]; // jpeg, png, webp

    // Resize to 800px width and compress
    const imageSharp = sharp(req.file.buffer).resize({ width: 800 });

    if (format === 'jpeg' || format === 'jpg') {
      await imageSharp.jpeg({ quality: 80 }).toFile(filepath);
    } else if (format === 'png') {
      await imageSharp.png({ compressionLevel: 8 }).toFile(filepath);
    } else if (format === 'webp') {
      await imageSharp.webp({ quality: 80 }).toFile(filepath);
    } else {
      await imageSharp.toFile(filepath); // fallback
    }

    // Save info for controller
    req.file.filename = filename;
    req.file.path = `/uploads/events/${filename}`;

    next();
  } catch (error) {
    next(error);
  }
};

module.exports = { uploadEventImage, resizeEventImage };
