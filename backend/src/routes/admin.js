const express = require('express');
const router = express.Router();
const Complaint = require('../models/Complaint');
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

module.exports = router;
