const express = require('express');
const router = express.Router();
const Complaint = require('../models/Complaint');
const Contractor = require('../models/Contractor');
const { GovernmentAdmin, RolesLegend, SummaryTable } = require('../models/AdminModels');
const { protect, authorize } = require('../middleware/auth');

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


router.get('/complaints', protect, authorize('admin', 'department_head'), async (req, res) => {
  const complaints = await Complaint.findAll();
  res.json(complaints);
});

router.put('/complaints/:id/assign', protect, authorize('admin', 'department_head'), async (req, res) => {
  const complaint = await Complaint.findByPk(req.params.id);
  if (!complaint) return res.status(404).json({ error: 'Not found' });
  complaint.assignedTeamId = req.body.teamId;
  complaint.status = 'team_assigned';
  await complaint.save();
  res.json(complaint);
});

router.get('/contractors', protect, async (req, res) => {
  const data = await Contractor.findAll();
  res.json(data);
});

router.post('/contractors', protect, authorize('admin'), async (req, res) => {
  const data = await Contractor.create(req.body);
  res.status(201).json(data);
});

router.get('/government', protect, async (req, res) => {
  const data = await GovernmentAdmin.findAll();
  res.json(data);
});

router.get('/roles', async (req, res) => {
  const data = await RolesLegend.findAll();
  res.json(data);
});

router.get('/summary', protect, async (req, res) => {
  const data = await SummaryTable.findAll();
  res.json(data);
});

module.exports = router;

