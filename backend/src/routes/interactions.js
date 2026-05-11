const express = require('express');
const router = express.Router();
const { Like, Confirmation } = require('../models/Interactions');
const Comment = require('../models/Comment');
const Complaint = require('../models/Complaint');
const { protect, authorize } = require('../middleware/auth');

/**
 * @swagger
 * /api/likes:
 *   post:
 *     summary: Like complaint
 *     tags: [Community Interactions]
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
 *               complaintId: { type: string }
 *     responses:
 *       200: { description: OK }
 */
router.post('/likes', protect, authorize('citizen'), async (req, res) => {
  try {
    const { complaintId } = req.body;
    const [like, created] = await Like.findOrCreate({
      where: { userId: req.user.id, complaintId }
    });

    if (created) {
      await Complaint.increment('likesCount', { where: { id: complaintId } });
      res.json({ message: 'Liked' });
    } else {
      await Like.destroy({ where: { userId: req.user.id, complaintId } });
      await Complaint.decrement('likesCount', { where: { id: complaintId } });
      res.json({ message: 'Unliked' });
    }
  } catch (error) { res.status(400).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/confirmations:
 *   post:
 *     summary: Confirm complaint
 *     tags: [Community Interactions]
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
 *               complaintId: { type: string }
 *     responses:
 *       200: { description: OK }
 */
router.post('/confirmations', protect, authorize('citizen'), async (req, res) => {
  try {
    const { complaintId } = req.body;
    const [conf, created] = await Confirmation.findOrCreate({
      where: { userId: req.user.id, complaintId }
    });
    if (created) {
        await Complaint.increment('confirmationCount', { where: { id: complaintId } });
        res.json({ message: 'Confirmed' });
    } else {
        res.status(400).json({ message: 'Already confirmed' });
    }
  } catch (error) { res.status(400).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/comments:
 *   post:
 *     summary: Add comment
 *     tags: [Community Interactions]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [complaintId, content]
 *             properties:
 *               complaintId: { type: string }
 *               content: { type: string }
 *     responses:
 *       201: { description: Comment added }
 */
router.post('/comments', protect, authorize('citizen'), async (req, res) => {
  try {
    const { complaintId, content } = req.body;
    const comment = await Comment.create({
      content,
      complaintId,
      userId: req.user.id
    });
    res.status(201).json(comment);
  } catch (error) { res.status(400).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/comments/{id}:
 *   delete:
 *     summary: Delete comment
 *     tags: [Community Interactions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 */
router.delete('/comments/:id', protect, authorize('admin'), async (req, res) => {
  try {
    await Comment.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Comment deleted' });
  } catch (error) { res.status(400).json({ error: error.message }); }
});

module.exports = router;
