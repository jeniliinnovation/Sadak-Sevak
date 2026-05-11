const express = require('express');
const router = express.Router();
const Complaint = require('../models/Complaint');
const { LiveMap } = require('../models/MissingModules');
const { Op } = require('sequelize');

/**
 * @swagger
 * /api/map/live:
 *   get:
 *     summary: Get live map configuration
 *     tags: [Map]
 */
router.get('/live', async (req, res) => {
  const data = await LiveMap.findAll();
  res.json(data);
});


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

/**
 * @swagger

 * /api/map/summary:
 *   get:
 *     summary: Get complaints summary by Area/Zone
 *     tags: [Map]
 *     responses:
 *       200: { description: OK }
 */
router.get('/summary', async (req, res) => {
  try {
    const complaints = await Complaint.findAll({ attributes: ['location'] });
    
    const summary = {
      byZone: {},
      byWard: {},
      byArea: {}
    };

    complaints.forEach(c => {
      const loc = c.location;
      if (loc.zone) summary.byZone[loc.zone] = (summary.byZone[loc.zone] || 0) + 1;
      if (loc.ward) summary.byWard[loc.ward] = (summary.byWard[loc.ward] || 0) + 1;
      if (loc.area) summary.byArea[loc.area] = (summary.byArea[loc.area] || 0) + 1;
    });

    res.json(summary);
  } catch (error) { res.status(500).json({ error: error.message }); }
});

router.get('/complaints', async (req, res) => {
  const pins = await Complaint.findAll({ attributes: ['id', 'location'] });
  res.json(pins);
});

router.get('/zone/:lat/:lng', (req, res) => {
  res.json({ zone: 'moderate', lat: req.params.lat, lng: req.params.lng });
});

module.exports = router;

