const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');

// 🧠 1. Memory storage (keeps file in RAM for sharp processing)
const storage = multer.memoryStorage();

// ✅ 2. File filter (restrict image types)
const fileFilter = (req, file, cb) => {
  const allowed = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'];
  if (allowed.includes(file.mimetype)) cb(null, true);
  else cb(new Error('Invalid image format. Allowed: JPG, PNG, WEBP'), false);
};

// ✅ 3. Add file size limit (10 MB recommended)
const uploadEventImage = multer({
  storage,
  fileFilter,
  limits: { fileSize: 10 * 1024 * 1024 }, // 10 MB
});

// ✅ 4. Resize & compress image with sharp
const resizeEventImage = async (req, res, next) => {
  if (!req.file) return next();

  try {
    const uploadDir = path.join(__dirname, '../../uploads/events');
    fs.mkdirSync(uploadDir, { recursive: true });

    const timestamp = Date.now();
    const ext = path.extname(req.file.originalname);
    const filename = `${timestamp}-${req.file.fieldname}${ext}`;
    const filepath = path.join(uploadDir, filename);

    // Determine format
    const format = req.file.mimetype.split('/')[1];

    const imageSharp = sharp(req.file.buffer).resize({ width: 800 });

    if (format === 'jpeg' || format === 'jpg') {
      await imageSharp.jpeg({ quality: 80 }).toFile(filepath);
    } else if (format === 'png') {
      await imageSharp.png({ compressionLevel: 8 }).toFile(filepath);
    } else if (format === 'webp') {
      await imageSharp.webp({ quality: 80 }).toFile(filepath);
    } else {
      await imageSharp.toFile(filepath);
    }

    req.file.filename = filename;
    req.file.path = `/uploads/events/${filename}`;
    next();
  } catch (error) {
    next(error);
  }
};

module.exports = { uploadEventImage, resizeEventImage };
