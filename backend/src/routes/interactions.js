const express = require('express');
const router = express.Router();
const { Like, Confirmation } = require('../models/Interactions');
const Comment = require('../models/Comment');
const Complaint = require('../models/Complaint');
const User = require('../models/User');
const { protect, authorize } = require('../middleware/auth');

/**
 * @swagger
 * /api/complaints/{id}/like:
 *   post:
 *     summary: Like/Unlike complaint
 *     tags: [Community Interactions]
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
router.post('/complaints/:id/like', protect, authorize('citizen'), async (req, res) => {
  try {
    const complaintId = req.params.id;
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
 * /api/complaints/{id}/confirm:
 *   post:
 *     summary: Confirm complaint presence
 *     tags: [Community Interactions]
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
router.post('/complaints/:id/confirm', protect, authorize('citizen'), async (req, res) => {
  try {
    const complaintId = req.params.id;
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
 * /api/complaints/{id}/comments:
 *   get:
 *     summary: Get all comments for a complaint
 *     tags: [Community Interactions]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: List of comments }
 *   post:
 *     summary: Add comment to complaint
 *     tags: [Community Interactions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [content]
 *             properties:
 *               content: { type: string }
 *     responses:
 *       201: { description: Comment added }
 */
router.get('/complaints/:id/comments', async (req, res) => {
  try {
    const comments = await Comment.findAll({ 
      where: { complaintId: req.params.id },
      include: [{ model: User, attributes: ['name', 'avatar'] }]
    });
    res.json(comments);
  } catch (error) { res.status(500).json({ error: error.message }); }
});

router.post('/complaints/:id/comments', protect, authorize('citizen'), async (req, res) => {
  try {
    const { content } = req.body;
    const comment = await Comment.create({
      content,
      complaintId: req.params.id,
      userId: req.user.id
    });
    res.status(201).json(comment);
  } catch (error) { res.status(400).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/complaints/{id}/interactions:
 *   get:
 *     summary: Get interaction counts/summary
 *     tags: [Community Interactions]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Interaction summary
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 likesCount: { type: number }
 *                 confirmationCount: { type: number }
 *                 commentsCount: { type: number }
 */
router.get('/complaints/:id/interactions', async (req, res) => {
  try {
    const complaint = await Complaint.findByPk(req.params.id, {
      attributes: ['likesCount', 'confirmationCount']
    });
    const commentsCount = await Comment.count({ where: { complaintId: req.params.id } });
    res.json({ ...complaint.toJSON(), commentsCount });
  } catch (error) { res.status(500).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/comments/{id}:
 *   delete:
 *     summary: Delete comment (Admin only)
 *     tags: [Community Interactions]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: Comment deleted }
 */
router.delete('/comments/:id', protect, authorize('admin'), async (req, res) => {
  try {
    await Comment.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Comment deleted' });
  } catch (error) { res.status(400).json({ error: error.message }); }
});

module.exports = router;
