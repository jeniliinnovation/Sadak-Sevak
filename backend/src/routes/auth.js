const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
const router = express.Router();

/**
 * @swagger
 * /api/auth/register:
 *   post:
 *     summary: Register a new user
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
 *     summary: Login user
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
 * /api/auth/me:
 *   get:
 *     summary: Get current profile
 *     tags: [Auth]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200: { description: Profile data }
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

const { protect } = require('../middleware/auth');
router.get('/me', protect, async (req, res) => { res.json(req.user); });

module.exports = router;
