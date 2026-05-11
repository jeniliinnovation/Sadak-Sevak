const express = require('express');
const router = express.Router();
const Complaint = require('../models/Complaint');
const { protect, authorize } = require('../middleware/auth');

/**
 * @swagger
 * /api/ai/analyze:
 *   post:
 *     summary: Trigger AI analysis (Simulation)
 *     tags: [AI Analysis]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               complaintId: { type: string, example: "uuid-here" }
 *     responses:
 *       200: { description: OK }
 */

/**
 * @swagger
 * /api/ai/score/{id}:
 *   get:
 *     summary: Get Road Health Score
 *     tags: [AI Analysis]
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
 * /api/ai/severity/{id}:
 *   get:
 *     summary: Get Damage Severity
 *     tags: [AI Analysis]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: OK }
 */


router.post('/analyze', protect, async (req, res) => {
  const { complaintId } = req.body;
  const complaint = await Complaint.findByPk(complaintId);
  if (!complaint) return res.status(404).json({ error: 'Not found' });
  complaint.aiResults = { roadHealthScore: 75, riskLevel: 'Medium', damageType: 'Pothole' };
  await complaint.save();
  res.json({ message: 'Analysis complete', results: complaint.aiResults });
});

router.get('/score/:id', async (req, res) => {
  const complaint = await Complaint.findByPk(req.params.id);
  res.json({ score: complaint ? complaint.aiResults.roadHealthScore : 0 });
});

router.get('/severity/:id', (req, res) => { res.json({ severity: 'High' }); });

module.exports = router;
