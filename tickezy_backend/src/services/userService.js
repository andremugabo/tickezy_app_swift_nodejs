// src/services/userService.js
const { User } = require('../');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const generateToken = (user) => {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '1d' }
  );
};

const registerUser = async ({ name, email, password, phoneNumber }) => {
  const existingUser = await User.findOne({ where: { email } });
  if (existingUser) throw new Error('Email already registered');

  const user = await User.create({ name, email, password, phoneNumber });
  const token = generateToken(user);

  return { user, token };
};

const loginUser = async ({ email, password }) => {
  const user = await User.findOne({ where: { email } });
  if (!user) throw new Error('Invalid credentials');

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) throw new Error('Invalid credentials');

  user.lastLoginAt = new Date();
  await user.save();

  const token = generateToken(user);
  return { user, token };
};

const getUserProfile = async (id) => {
  const user = await User.findByPk(id);
  if (!user) throw new Error('User not found');
  return user;
};

module.exports = { registerUser, loginUser, getUserProfile };
