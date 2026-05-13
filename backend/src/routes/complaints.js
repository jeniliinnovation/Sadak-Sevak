const express = require('express');
const router = express.Router();
const Complaint = require('../models/Complaint');
const User = require('../models/User');
const { protect, authorize } = require('../middleware/auth');
const { enrichLocation } = require('../utils/locationService');

/**
 * @swagger
 * /api/complaints:
 *   post:
 *     summary: Create complaint
 *     tags: [Complaints]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [title, description]
 *             properties:
 *               title: { type: string, example: "Large Pothole on MG Road" }
 *               description: { type: string, example: "The pothole is about 5 inches deep and dangerous for bikes." }
 *               location: 
 *                 type: object
 *                 properties:
 *                   lat: { type: number, example: 19.0760 }
 *                   lng: { type: number, example: 72.8777 }
 *     responses:
 *       201: { description: Complaint created with SARA enrichment }
 *   get:
 *     summary: Get all complaints
 *     tags: [Complaints]
 *     responses:
 *       200: { description: OK }
 */

/**
 * @swagger
 * /api/complaints/{id}:
 *   get:
 *     summary: Get complaint details
 *     tags: [Complaints]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: OK }
 *   delete:
 *     summary: Delete complaint
 *     tags: [Complaints]
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

/**
 * @swagger
 * /api/complaints/{id}/status:
 *   put:
 *     summary: Update complaint status
 *     tags: [Complaints]
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
 *             required: [status]
 *             properties:
 *               status: { type: string, enum: [under_review, team_assigned, repair_started, repair_completed] }
 *     responses:
 *       200: { description: OK }
 */


router.post('/', protect, authorize('citizen'), async (req, res) => {
  try {
    const { title, description, location, media } = req.body;
    
    // SARA Enrichment (Async DB Query)
    const enrichedLocation = await enrichLocation(location.lat, location.lng);
    
    const complaint = await Complaint.create({
      title,
      description,
      media: media || { url: 'https://example.com/placeholder.jpg', type: 'image' },
      location: enrichedLocation,
      citizenId: req.user.id,
      status: 'submitted'
    });
    res.status(201).json(complaint);
  } catch (error) { res.status(400).json({ error: error.message }); }
});


router.get('/:id', async (req, res) => {
  const complaint = await Complaint.findByPk(req.params.id, { include: [{ model: User, as: 'citizen', attributes: ['name'] }] });
  if (!complaint) return res.status(404).json({ error: 'Not found' });
  res.json(complaint);
});

router.put('/:id/status', protect, authorize('admin', 'department_head', 'team_member'), async (req, res) => {
  try {
    const complaint = await Complaint.findByPk(req.params.id);
    if (!complaint) return res.status(404).json({ error: 'Not found' });
    complaint.status = req.body.status;
    await complaint.save();
    res.json(complaint);
  } catch (error) { res.status(400).json({ error: error.message }); }
});

router.delete('/:id', protect, authorize('admin'), async (req, res) => {
  await Complaint.destroy({ where: { id: req.params.id } });
  res.json({ message: 'Deleted' });
});

/**
 * @swagger
 * /api/complaints/my:
 *   get:
 *     summary: Get my complaints
 *     tags: [Complaints]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: List of complaints
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items: { type: object }
 */
router.get('/my', protect, async (req, res) => {
  try {
    const complaints = await Complaint.findAll({ where: { citizenId: req.user.id } });
    res.json(complaints);
  } catch (error) { res.status(500).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/complaints/{id}/verify:
 *   post:
 *     summary: Verify repair completion
 *     tags: [Complaints]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: Verified and closed }
 */
router.post('/:id/verify', protect, authorize('citizen'), async (req, res) => {
  try {
    const complaint = await Complaint.findByPk(req.params.id);
    if (!complaint) return res.status(404).json({ error: 'Not found' });
    if (complaint.citizenId !== req.user.id) return res.status(403).json({ error: 'Unauthorized' });
    
    complaint.status = 'verified_closed';
    await complaint.save();
    res.json({ message: 'Complaint verified and closed', complaint });
  } catch (error) { res.status(400).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/complaints/{id}/reopen:
 *   post:
 *     summary: Reopen a closed complaint
 *     tags: [Complaints]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200: { description: Reopened }
 */
router.post('/:id/reopen', protect, authorize('citizen'), async (req, res) => {
  try {
    const complaint = await Complaint.findByPk(req.params.id);
    if (!complaint) return res.status(404).json({ error: 'Not found' });
    if (complaint.citizenId !== req.user.id) return res.status(403).json({ error: 'Unauthorized' });
    
    complaint.status = 'reopened';
    await complaint.save();
    res.json({ message: 'Complaint reopened', complaint });
  } catch (error) { res.status(400).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/complaints/nearby:
 *   get:
 *     summary: Get nearby complaints
 *     tags: [Complaints]
 *     parameters:
 *       - in: query
 *         name: lat
 *         required: true
 *         schema: { type: number, example: 19.0760 }
 *       - in: query
 *         name: lng
 *         required: true
 *         schema: { type: number, example: 72.8777 }
 *       - in: query
 *         name: radius
 *         schema: { type: number, default: 5, example: 10 }
 *     responses:
 *       200:
 *         description: List of nearby complaints
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items: { type: object }
 */
router.get('/nearby', async (req, res) => {
  try {
    // Simple mock for now, returning all as nearby
    const complaints = await Complaint.findAll();
    res.json(complaints);
  } catch (error) { res.status(500).json({ error: error.message }); }
});

router.get('/', async (req, res) => {
  const complaints = await Complaint.findAll({ include: [{ model: User, as: 'citizen', attributes: ['name'] }] });
  res.json(complaints);
});

module.exports = router;

