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
 *     summary: Overdue reports
 *     tags: [Escalation]
 *     responses:
 *       200: { description: OK }
 */

/**
 * @swagger
 * /api/escalation/{id}:
 *   post:
 *     summary: Manual Escalation
 *     tags: [Escalation]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: OK }
 */

/**
 * @swagger
 * /api/escalation/auto:
 *   post:
 *     summary: Trigger System Escalation
 *     tags: [Escalation]
 *     responses:
 *       200: { description: OK }
 */

/**
 * @swagger
 * /api/escalation/central:
 *   get:
 *     summary: Central Monitoring Feed
 *     tags: [Escalation]
 *     responses:
 *       200: { description: OK }
 */

/**
 * @swagger
 * /api/escalation/history/{id}:
 *   get:
 *     summary: Audit trail
 *     tags: [Escalation]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: OK }
 */


router.get('/pending', protect, authorize('admin', 'department_head'), async (req, res) => {
  const overdue = await Complaint.findAll({ where: { deadline: { [Op.lt]: new Date() } } });
  res.json(overdue);
});

router.post('/:id', protect, authorize('admin', 'department_head'), (req, res) => { res.json({ message: 'Escalated' }); });
router.post('/auto', protect, authorize('admin'), (req, res) => { res.json({ message: 'Auto triggered' }); });
router.get('/central', protect, authorize('admin'), (req, res) => { res.json([]); });
router.get('/history/:id', protect, (req, res) => { res.json([]); });

module.exports = router;
