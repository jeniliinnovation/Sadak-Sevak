const express = require('express');
const router = express.Router();
const { RolesLegend } = require('../models/AdminModels');

/**
 * @swagger
 * /api/roles:
 *   get:
 *     summary: Get roles legend
 *     tags: [Public Information]
 *     responses:
 *       200: { description: OK }
 */

router.get('/', async (req, res) => {
  const data = await RolesLegend.findAll();
  res.json(data);
});

module.exports = router;
