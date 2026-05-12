const express = require('express');
const router = express.Router();
const Notification = require('../models/Notification');
const { protect, authorize } = require('../middleware/auth');

/**
 * @swagger
 * /api/notifications:
 *   get:
 *     summary: Get all notifications for current user
 *     tags: [Notifications]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of notifications
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items: { type: object }
 */
router.get('/', protect, async (req, res) => {
  const alerts = await Notification.findAll({ where: { userId: req.user.id } });
  res.json(alerts);
});

/**
 * @swagger
 * /api/notifications/{id}/read:
 *   put:
 *     summary: Mark a single notification as read
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
router.put('/:id/read', protect, async (req, res) => {
  const alert = await Notification.findOne({ where: { id: req.params.id, userId: req.user.id } });
  if (alert) { alert.isRead = true; await alert.save(); }
  res.json(alert);
});

module.exports = router;
