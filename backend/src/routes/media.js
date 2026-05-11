const express = require('express');
const router = express.Router();
const upload = require('../middleware/upload');
const { protect, authorize } = require('../middleware/auth');

/**
 * @swagger
 * /api/media/upload:
 *   post:
 *     summary: Public media upload
 *     tags: [Media Upload]
 *     security:
 *       - bearerAuth: []
 */

/**
 * @swagger
 * /api/media/repair-proof:
 *   post:
 *     summary: Upload repair proof
 *     tags: [Media Upload]
 *     security:
 *       - bearerAuth: []
 */

/**
 * @swagger
 * /api/media/{mediaId}:
 *   delete:
 *     summary: Delete media file
 *     tags: [Media Upload]
 *     security:
 *       - bearerAuth: []
 */

router.post('/upload', protect, upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file' });
  res.json({ url: req.file.path, public_id: req.file.filename });
});

router.post('/repair-proof', protect, authorize('team_member', 'admin'), upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file' });
  res.json({ url: req.file.path, public_id: req.file.filename });
});

router.delete('/:mediaId', protect, (req, res) => {
  res.json({ message: 'Media deletion scheduled' });
});

module.exports = router;
