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
    const { title, description, location } = req.body;
    
    // SARA Enrichment (Async DB Query)
    const enrichedLocation = await enrichLocation(location.lat, location.lng);
    
    const complaint = await Complaint.create({
      title,
      description,
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

router.get('/', async (req, res) => {
  const complaints = await Complaint.findAll({ include: [{ model: User, as: 'citizen', attributes: ['name'] }] });
  res.json(complaints);
});

module.exports = router;

