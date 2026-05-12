const express = require('express');
const router = express.Router();
const Complaint = require('../models/Complaint');
const { protect, authorize } = require('../middleware/auth');
const { Op } = require('sequelize');
const { sequelize } = require('../config/db');

/**
 * @swagger
 * /api/escalation/pending:
 *   get:
 *     summary: Get overdue reports
 *     tags: [Escalation]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of overdue complaints
 */
router.get('/pending', protect, authorize('admin', 'department_head'), async (req, res) => {
  const overdue = await Complaint.findAll({ where: { deadline: { [Op.lt]: new Date() } } });
  res.json(overdue);
});

/**
 * @swagger
 * /api/escalation/{id}:
 *   post:
 *     summary: Manual Escalation
 *     tags: [Escalation]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: OK }
 */
router.post('/:id', protect, authorize('admin', 'department_head'), (req, res) => { res.json({ message: 'Escalated' }); });

/**
 * @swagger
 * /api/escalation/auto:
 *   post:
 *     summary: Trigger System Escalation
 *     tags: [Escalation]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200: { description: OK }
 */
router.post('/auto', protect, authorize('admin'), (req, res) => { res.json({ message: 'Auto triggered' }); });

/**
 * @swagger
 * /api/escalation/central:
 *   get:
 *     summary: Central Monitoring Feed
 *     tags: [Escalation]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200: { description: OK }
 */
router.get('/central', protect, authorize('admin'), (req, res) => { res.json([]); });

/**
 * @swagger
 * /api/escalation/history/{id}:
 *   get:
 *     summary: View audit trail for a complaint
 *     tags: [Escalation]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: OK }
 */
router.get('/history/:id', protect, (req, res) => { res.json([]); });

module.exports = router;
