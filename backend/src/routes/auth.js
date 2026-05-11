const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const router = express.Router();

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Register a new citizen
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [name, email, password]
 *             properties:
 *               name: { type: string, example: "John Doe" }
 *               email: { type: string, example: "john@gmail.com" }
 *               password: { type: string, example: "password123" }
 *               role: { type: string, enum: [citizen, team_member, department_head, admin], default: citizen }
 *     responses:
 *       201: { description: User created }
 */

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: User login
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, password]
 *             properties:
 *               email: { type: string, example: "john@gmail.com" }
 *               password: { type: string, example: "password123" }
 *     responses:
 *       200: { description: Login successful }
 */

/**
 * @swagger
 * /api/auth/verify-otp:
 *   post:
 *     summary: Verify OTP
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, otp]
 *             properties:
 *               email: { type: string, example: "john@gmail.com" }
 *               otp: { type: string, example: "123456" }
 *     responses:
 *       200: { description: OTP Verified }
 *       400: { description: Invalid OTP }
 */

/**
 * @swagger
 * /api/auth/profile:
 *   get:
 *     summary: Get user profile
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200: { description: Profile data }
 */

/**
 * @swagger
 * /api/auth/users:
 *   get:
 *     summary: Get all users
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200: { description: List of users }
 */

router.post('/register', async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) return res.status(400).json({ error: 'User already exists' });
    const user = await User.create({ name, email, password: await bcrypt.hash(password, 10), role: role || 'citizen' });
    res.status(201).json({ id: user.id, name: user.name, email: user.email, role: user.role });
  } catch (error) { res.status(400).json({ error: error.message }); }
});

router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user || !(await bcrypt.compare(password, user.password))) return res.status(401).json({ error: 'Invalid credentials' });
    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.json({ id: user.id, name: user.name, role: user.role, token });
  } catch (error) { res.status(500).json({ error: error.message }); }
});

router.post('/verify-otp', async (req, res) => {
  const { email, otp } = req.body;
  // Mock OTP verification
  if (otp === '123456') {
    res.json({ message: 'OTP Verified successfully' });
  } else {
    res.status(400).json({ error: 'Invalid or expired OTP' });
  }
});

const { protect, authorize } = require('../middleware/auth');

router.get('/profile', protect, async (req, res) => { 
  res.json(req.user); 
});

router.get('/users', protect, authorize('admin'), async (req, res) => {
  try {
    const users = await User.findAll({ attributes: { exclude: ['password'] } });
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

