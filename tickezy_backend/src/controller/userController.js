const jwt = require('jsonwebtoken');
const Joi = require('joi');
const bcrypt = require('bcrypt');
const { User } = require('../models');

/**
 * 📦 Validation Schemas
 */
const registerSchema = Joi.object({
  name: Joi.string().min(2).max(100).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  phoneNumber: Joi.string().optional(),
  role: Joi.string().valid('ADMIN', 'CUSTOMER').optional(), // optional for admin creation
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

/**
 * 🧩 Helper: Generate JWT Token
 */
const generateToken = (user) =>
  jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
  );

/**
 * 🧍 Register a new user
 */
exports.register = async (req, res) => {
  try {
    const { error, value } = registerSchema.validate(req.body, { abortEarly: false });
    if (error)
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        details: error.details.map((d) => d.message),
      });

    const { name, email, password, phoneNumber, role } = value;
    const normalizedEmail = email.trim().toLowerCase();

    // Check if user already exists
    const existingUser = await User.findOne({ where: { email: normalizedEmail } });
    if (existingUser)
      return res.status(400).json({ success: false, message: 'Email already registered' });

    // Create user
    const user = await User.create({
      name,
      email: normalizedEmail,
      password,
      phoneNumber,
      role: role || 'CUSTOMER',
    });

    const token = generateToken(user);

    return res.status(201).json({
      success: true,
      message: 'User registered successfully',
      token,
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    console.error('❌ Register error:', err);
    res.status(500).json({ success: false, message: 'Server error during registration' });
  }
};

/**
 * 🔐 Login an existing user
 */
exports.login = async (req, res) => {
  try {
    const { error, value } = loginSchema.validate(req.body, { abortEarly: false });
    if (error)
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        details: error.details.map((d) => d.message),
      });

    const { email, password } = value;
    const normalizedEmail = email.trim().toLowerCase();

    // Find user
    const user = await User.findOne({ where: { email: normalizedEmail } });
    if (!user)
      return res.status(401).json({ success: false, message: 'Invalid email or password' });

    // Compare password
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword)
      return res.status(401).json({ success: false, message: 'Invalid email or password' });

    // Update last login timestamp
    user.lastLoginAt = new Date();
    await user.save();

    const token = generateToken(user);

    return res.status(200).json({
      success: true,
      message: 'Login successful',
      token,
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (err) {
    console.error('❌ Login error:', err);
    res.status(500).json({ success: false, message: 'Server error during login' });
  }
};

/**
 * 👤 Get logged-in user's profile
 */
exports.getProfile = async (req, res) => {
  try {
    const user = req.user; // Populated by authMiddleware

    if (!user)
      return res.status(404).json({ success: false, message: 'User not found' });

    return res.status(200).json({
      success: true,
      data: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        phoneNumber: user.phoneNumber,
        createdAt: user.createdAt,
      },
    });
  } catch (err) {
    console.error('❌ Get profile error:', err);
    res.status(500).json({ success: false, message: 'Server error retrieving profile' });
  }
};


exports.getAllUsers = async (req, res) => {
    try {
      const users = await User.findAll({
        attributes: { exclude: ['password'] } // don't return passwords
      });
      res.status(200).json({ success: true, data: users });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, message: 'Server error fetching users' });
    }
  };
  