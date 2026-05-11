const express = require('express');
const router = express.Router();
const Area = require('../models/Area');
const { protect, authorize } = require('../middleware/auth');

/**
 * @swagger
 * /api/areas:
 *   get:
 *     summary: Get all SARA areas
 *     responses:
 *       200: { description: OK }
 *   post:
 *     summary: Create new SARA area
 *     tags: [SARA / Map]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [zoneName, wardName, latMin, latMax, lngMin, lngMax]
 *             properties:
 *               zoneName: { type: string, example: "North Zone" }
 *               wardName: { type: string, example: "Ward 1" }
 *               latMin: { type: number, example: 19.2 }
 *               latMax: { type: number, example: 19.3 }
 *               lngMin: { type: number, example: 72.8 }
 *               lngMax: { type: number, example: 72.9 }
 *     responses:
 *       201: { description: Area created }
 */


router.get('/', async (req, res) => {
  const data = await Area.findAll();
  res.json(data);
});

router.post('/', protect, authorize('admin'), async (req, res) => {
  const data = await Area.create(req.body);
  res.status(201).json(data);
});

module.exports = router;
