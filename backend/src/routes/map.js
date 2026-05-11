const express = require('express');
const router = express.Router();
const Complaint = require('../models/Complaint');
const { Op } = require('sequelize');

/**
 * @swagger
 * /api/map/complaints:
 *   get:
 *     summary: Geo-pins feed
 *     tags: [Map]
 */

/**
 * @swagger
 * /api/map/zone/{lat}/{lng}:
 *   get:
 *     summary: Zone status check
 *     tags: [Map]
 *     parameters:
 *       - in: path
 *         name: lat
 *         required: true
 *         schema: { type: number, example: 19.0760 }
 *       - in: path
 *         name: lng
 *         required: true
 *         schema: { type: number, example: 72.8777 }
 *     responses:
 *       200: { description: OK }
 */

router.get('/complaints', async (req, res) => {
  const pins = await Complaint.findAll({ attributes: ['id', 'location'] });
  res.json(pins);
});

router.get('/zone/:lat/:lng', (req, res) => {
  res.json({ zone: 'moderate', lat: req.params.lat, lng: req.params.lng });
});

module.exports = router;
