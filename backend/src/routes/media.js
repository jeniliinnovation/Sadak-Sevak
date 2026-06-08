const express = require('express');
const router = express.Router();
const multer = require('multer');
const { storage, cloudinary } = require('../config/cloudinary');
const { protect, authorize } = require('../middleware/auth');

const upload = multer({ storage });

/**
 * @swagger
 * /api/media/upload:
 *   post:
 *     summary: Public media upload
 *     tags: [Media Upload]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               file:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200: 
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 url: { type: string }
 *                 public_id: { type: string }
 */
router.post('/upload', protect, upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file' });
  res.json({ 
    url: req.file.path, 
    public_id: req.file.filename 
  });
});

router.post('/repair-proof', protect, authorize('team_member', 'admin'), upload.single('file'), (req, res) => {
  if (!req.file) return res.status(400).json({ error: 'No file' });
  res.json({ 
    url: req.file.path, 
    public_id: req.file.filename 
  });
});

router.delete('/:mediaId', protect, async (req, res) => {
  try {
    await cloudinary.uploader.destroy(req.params.mediaId);
    res.json({ message: 'Media deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
