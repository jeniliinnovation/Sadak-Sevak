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
 *             required: [complaintId]
 *             properties:
 *               complaintId: { type: string, example: "complaint-uuid-123" }
 *     responses:
 *       200:
 *         description: Analysis complete
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 message: { type: string }
 *                 results: { type: object }
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
