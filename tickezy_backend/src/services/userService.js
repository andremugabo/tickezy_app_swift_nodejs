// src/services/userService.js

const { User } = require('../models'); // adjust path if needed
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

// Generate JWT token
const generateToken = (user) => {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
  );
};

// Register new user
const registerUser = async ({ name, email, password, phoneNumber }) => {
  // Check if email is already taken
  const existingUser = await User.findOne({ where: { email } });
  if (existingUser) throw new Error('Email already registered');

  // Create user (password hashing is handled in model hooks)
  const user = await User.create({
    name,
    email,
    password,
    phoneNumber
  });

  const token = generateToken(user);

  return { user, token };
};

// Login user
const loginUser = async ({ email, password }) => {
  const user = await User.findOne({ where: { email } });
  if (!user) throw new Error('Invalid credentials');

  // Compare raw password with hashed password
  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) throw new Error('Invalid credentials');

  // Update last login time
  user.lastLoginAt = new Date();
  await user.save();

  const token = generateToken(user);

  return { user, token };
};

// Get user profile
const getUserProfile = async (id) => {
  const user = await User.findByPk(id);
  if (!user) throw new Error('User not found');
  return user;
};

module.exports = {
  registerUser,
  loginUser,
  getUserProfile
};
