const express = require('express');
const router = express.Router();
const Complaint = require('../models/Complaint');
const Contractor = require('../models/Contractor');
const User = require('../models/User');
const { GovernmentAdmin, RolesLegend, SummaryTable } = require('../models/AdminModels');
const { protect, authorize } = require('../middleware/auth');
const { Op } = require('sequelize');

/**
 * @swagger
 * /api/admin/complaints/{id}/assign:
 *   put:
 *     summary: Assign Field Team
 *     tags: [Government / Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [teamId]
 *             properties:
 *               teamId: { type: string, example: "team-uuid" }
 *     responses:
 *       200: { description: OK }
 */

/**
 * @swagger
 * /api/admin/contractors:
 *   get:
 *     summary: Get all contractors
 *     tags: [Government / Admin]
 *     responses:
 *       200: { description: OK }
 *   post:
 *     summary: Add a new contractor
 *     tags: [Government / Admin]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [companyName]
 *             properties:
 *               companyName: { type: string, example: "City Road Services" }
 *               specialization: { type: string, example: "Pothole Repair" }
 *     responses:
 *       201: { description: Contractor created }
 */


/**
 * @swagger
 * /api/admin/government:
 *   get:
 *     summary: Get government admin details
 *     tags: [Government / Admin]
 *     responses:
 *       200: { description: OK }
 */

/**
 * @swagger
 * /api/admin/roles:
 *   get:
 *     summary: Get roles legend
 *     tags: [Government / Admin]
 *     responses:
 *       200: { description: OK }
 */

/**
 * @swagger
 * /api/admin/summary:
 *   get:
 *     summary: Get performance summary
 *     tags: [Government / Admin]
 *     responses:
 *       200: { description: OK }
 */


/**
 * @swagger
 * /api/admin/complaints:
 *   get:
 *     summary: Get all complaints (Admin/Gov Head only)
 *     tags: [Government / Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of all complaints
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items: { type: object }
 */
router.get('/complaints', protect, async (req, res) => {
  const complaints = await Complaint.findAll({
    include: [
      { model: User, as: 'citizen', attributes: ['name'] },
      { model: User, as: 'team', attributes: ['name'] }
    ]
  });
  res.json(complaints);
});

router.put('/complaints/:id/assign', protect, authorize('admin', 'department_head', 'government', 'team_member'), async (req, res) => {
  const complaint = await Complaint.findByPk(req.params.id);
  if (!complaint) return res.status(404).json({ error: 'Not found' });
  complaint.assignedTeamId = req.body.teamId;
  complaint.status = 'team_assigned';
  await complaint.save();
  await complaint.reload({
    include: [
      { model: User, as: 'citizen', attributes: ['name'] },
      { model: User, as: 'team', attributes: ['name'] }
    ]
  });
  res.json(complaint);
});

/**
 * @swagger
 * /api/admin/contractors:
 *   get:
 *     summary: Get all contractors
 *     tags: [Government / Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of contractors
 *   post:
 *     summary: Add a new contractor
 *     tags: [Government / Admin]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [companyName]
 *             properties:
 *               companyName: { type: string, example: "City Road Services" }
 *               specialization: { type: string, example: "Pothole Repair" }
 */
router.get('/contractors', protect, async (req, res) => {
  const data = await Contractor.findAll();
  res.json(data);
});

router.post('/contractors', protect, authorize('admin'), async (req, res) => {
  const data = await Contractor.create(req.body);
  res.status(201).json(data);
});

/**
 * @swagger
 * /api/admin/government:
 *   get:
 *     summary: Get government admin details
 *     tags: [Government / Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200: { description: OK }
 */
router.get('/government', protect, async (req, res) => {
  const data = await GovernmentAdmin.findAll();
  res.json(data);
});

/**
 * @swagger
 * /api/admin/roles:
 *   get:
 *     summary: Get roles legend
 *     tags: [Government / Admin]
 *     responses:
 *       200: { description: OK }
 */
router.get('/roles', async (req, res) => {
  const data = await RolesLegend.findAll();
  res.json(data);
});

/**
 * @swagger
 * /api/admin/summary:
 *   get:
 *     summary: Get performance summary
 *     tags: [Government / Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200: { description: OK }
 */
router.get('/summary', protect, async (req, res) => {
  const data = await SummaryTable.findAll();
  res.json(data);
});

/**
 * @swagger
 * /api/admin/users/{id}:
 *   put:
 *     summary: Update user role or status
 *     tags: [Government / Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               role: { type: string, enum: [citizen, team_member, department_head, admin], example: "team_member" }
 *               isVerified: { type: boolean, example: true }
 *     responses:
 *       200: { description: User updated }
 *   delete:
 *     summary: Delete user
 *     tags: [Government / Admin]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: User deleted }
 */
/**
 * @swagger
 * /api/admin/users:
 *   get:
 *     summary: Get all government staff users
 *     tags: [Government / Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of government staff users
 */
router.get('/users', protect, async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: { exclude: ['password', 'otp', 'googleId', 'appleId'] },
      order: [['createdAt', 'DESC']]
    });
    res.json(users);
  } catch (error) { res.status(500).json({ error: error.message }); }
});

router.put('/users/:id', protect, authorize('admin'), async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ error: 'User not found' });
    const { role, isVerified } = req.body;
    if (role) user.role = role;
    if (isVerified !== undefined) user.isVerified = isVerified;
    await user.save();
    res.json(user);
  } catch (error) { res.status(400).json({ error: error.message }); }
});

router.delete('/users/:id', protect, authorize('admin'), async (req, res) => {
  try {
    await User.destroy({ where: { id: req.params.id } });
    res.json({ message: 'User deleted' });
  } catch (error) { res.status(400).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/admin/inactive:
 *   get:
 *     summary: List inactive departments or users
 *     tags: [Government / Admin]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of inactive entities
 */
router.get('/inactive', protect, authorize('admin'), async (req, res) => {
  res.json([]); // Placeholder for complex inactive logic
});

module.exports = router;

