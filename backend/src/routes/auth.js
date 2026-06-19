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
 *               role: { type: string, enum: [citizen, team_member, department_head, admin, contractor], default: citizen }
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
    console.log('Login attempt:', { email, password });
    const user = await User.findOne({ where: { email } });
    if (!user || !(await bcrypt.compare(password, user.password))) return res.status(401).json({ error: 'Invalid credentials' });
    const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '30d' });
    res.json({ id: user.id, name: user.name, email: user.email, role: user.role, token });
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

/**
 * @swagger
 * /api/auth/profile:
 *   get:
 *     summary: Get user profile
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile data
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id: { type: string }
 *                 name: { type: string }
 *                 email: { type: string }
 *                 role: { type: string }
 *                 avatar: { type: string }
 */
router.get('/profile', protect, async (req, res) => { 
  res.json(req.user); 
});

/**
 * @swagger
 * /api/auth/me:
 *   get:
 *     summary: Get current user profile (alias for /profile)
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Profile data
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 id: { type: string, example: "uuid-v4" }
 *                 name: { type: string, example: "John Doe" }
 *                 email: { type: string, example: "john@example.com" }
 *                 role: { type: string, example: "citizen" }
 *   put:
 *     summary: Update user profile
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name: { type: string, example: "John Updated" }
 *               avatar: { type: string, example: "http://example.com/avatar.png" }
 *     responses:
 *       200:
 *         description: Profile updated
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string }
 *                 user: { type: object }
 */
router.get('/me', protect, async (req, res) => {
  res.json(req.user);
});

router.put('/me', protect, async (req, res) => {
  try {
    const { name, avatar } = req.body;
    const user = await User.findByPk(req.user.id);
    if (name) user.name = name;
    if (avatar) user.avatar = avatar;
    await user.save();
    res.json(user);
  } catch (error) { res.status(400).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/auth/logout:
 *   post:
 *     summary: Logout user
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Logged out
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Logged out successfully" }
 */
router.post('/logout', protect, (req, res) => {
  res.json({ message: 'Logged out successfully' });
});

/**
 * @swagger
 * /api/auth/refresh:
 *   post:
 *     summary: Refresh token
 *     tags: [Auth]
 *     responses:
 *       200:
 *         description: New token
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 token: { type: string, example: "eyJhbG..." }
 */
router.post('/refresh', async (req, res) => {
  // simple refresh mock for now
  res.json({ token: 'new-token-simulated' });
});

/**
 * @swagger
 * /api/auth/forgot-password:
 *   post:
 *     summary: Request password reset
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email]
 *             properties:
 *               email: { type: string, example: "john@example.com" }
 *     responses:
 *       200:
 *         description: OTP sent
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Reset OTP sent to email (Mock: 654321)" }
 */
router.post('/forgot-password', async (req, res) => {
  try {
    const { email } = req.body;
    const user = await User.findOne({ where: { email } });
    if (!user) return res.status(404).json({ error: 'User not found' });
    
    // Generate mock OTP
    user.otp = '654321';
    await user.save();
    
    res.json({ message: 'Reset OTP sent to email (Mock: 654321)' });
  } catch (error) { res.status(400).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/auth/reset-password:
 *   post:
 *     summary: Reset password with OTP
 *     tags: [Auth]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [email, otp, newPassword]
 *             properties:
 *               email: { type: string, example: "john@example.com" }
 *               otp: { type: string, example: "654321" }
 *               newPassword: { type: string, example: "NewPass123!" }
 *     responses:
 *       200:
 *         description: Password reset successful
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string, example: "Password reset successful" }
 */
router.post('/reset-password', async (req, res) => {
  try {
    const { email, otp, newPassword } = req.body;
    const user = await User.findOne({ where: { email, otp } });
    if (!user) return res.status(400).json({ error: 'Invalid OTP' });
    
    user.password = await bcrypt.hash(newPassword, 10);
    user.otp = null;
    await user.save();
    
    res.json({ message: 'Password reset successful' });
  } catch (error) { res.status(400).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/auth/users:
 *   get:
 *     summary: Get all users (Admin only)
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of users
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items:
 *                 type: object
 *                 properties:
 *                   id: { type: string }
 *                   name: { type: string }
 *                   email: { type: string }
 *                   role: { type: string }
 */
router.get('/users', protect, authorize('admin'), async (req, res) => {
  try {
    const users = await User.findAll({ attributes: { exclude: ['password'] } });
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;

