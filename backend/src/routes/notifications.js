const express = require('express');
const router = express.Router();
const Notification = require('../models/Notification');
const { protect, authorize } = require('../middleware/auth');

/**
 * @swagger
 * /api/notifications:
 *   get:
 *     summary: All Alerts
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200: { description: OK }
 */

/**
 * @swagger
 * /api/notifications/{id}/read:
 *   put:
 *     summary: Mark single read
 *     tags: [Notifications]
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


router.get('/', protect, async (req, res) => {
  const alerts = await Notification.findAll({ where: { userId: req.user.id } });
  res.json(alerts);
});

router.put('/:id/read', protect, async (req, res) => {
  const alert = await Notification.findOne({ where: { id: req.params.id, userId: req.user.id } });
  if (alert) { alert.isRead = true; await alert.save(); }
  res.json(alert);
});

module.exports = router;
