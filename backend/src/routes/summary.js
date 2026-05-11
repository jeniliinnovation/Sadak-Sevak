const express = require('express');
const router = express.Router();
const { SummaryTable } = require('../models/AdminModels');
const { protect } = require('../middleware/auth');

/**
 * @swagger
 * /api/summary:
 *   get:
 *     summary: Get overall performance summary
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200: { description: OK }
 */

router.get('/', protect, async (req, res) => {
  const data = await SummaryTable.findAll();
  res.json(data);
});

module.exports = router;
