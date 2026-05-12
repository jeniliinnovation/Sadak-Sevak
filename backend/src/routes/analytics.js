const express = require('express');
const router = express.Router();
const Complaint = require('../models/Complaint');
const { Analytics } = require('../models/MissingModules');
const { protect, authorize } = require('../middleware/auth');
const { sequelize } = require('../config/db');

/**
 * @swagger
 * /api/analytics/metrics:
 *   get:
 *     summary: Get all system metrics
 *     tags: [Analytics]
 *     responses:
 *       200:
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items: { type: object }
 */
router.get('/metrics', async (req, res) => {
  const data = await Analytics.findAll();
  res.json(data);
});

/**
 * @swagger
 * /api/analytics/complaints:
 *   get:
 *     summary: Trend Chart Data (Complaint status counts)
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items: { type: object }
 */
router.get('/complaints', protect, authorize('admin'), async (req, res) => {
  const stats = await Complaint.count({
    attributes: ['status'],
    group: 'status'
  });
  res.json(stats);
});

/**
 * @swagger
 * /api/analytics/zones:
 *   get:
 *     summary: Get zone-wise status
 *     tags: [Analytics]
 *     responses:
 *       200: { description: OK }
 */
router.get('/zones', async (req, res) => { 
  res.json([]); 
});

/**
 * @swagger
 * /api/analytics/repairs:
 *   get:
 *     summary: Get repair completion analytics
 *     tags: [Analytics]
 *     responses:
 *       200:
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 total: { type: number, example: 150 }
 *                 completed: { type: number, example: 125 }
 *                 rate: { type: string, example: "83%" }
 *                 avgTimeDays: { type: number, example: 4.5 }
 */
router.get('/repairs', (req, res) => { 
  res.json({ 
    total: 150, 
    completed: 125, 
    rate: '83%',
    avgTimeDays: 4.5
  }); 
});

/**
 * @swagger
 * /api/analytics/ai-accuracy:
 *   get:
 *     summary: Get AI classification accuracy metrics
 *     tags: [Analytics]
 *     responses:
 *       200:
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 overall: { type: string, example: "94.2%" }
 *                 potholeDetection: { type: string, example: "96.5%" }
 *                 severityScoring: { type: string, example: "91.8%" }
 */
router.get('/ai-accuracy', (req, res) => { 
  res.json({ 
    overall: '94.2%', 
    potholeDetection: '96.5%', 
    severityScoring: '91.8%' 
  }); 
});

module.exports = router;
