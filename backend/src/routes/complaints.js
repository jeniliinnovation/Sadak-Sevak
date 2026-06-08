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
 *       201: { description: Complaint created }
 */
router.post('/', protect, authorize('citizen'), async (req, res) => {
  try {
    const { title, description, location, media } = req.body;
    
    // SARA Enrichment (Async DB Query)
    const enrichedLocation = await enrichLocation(location.lat, location.lng);
    
    // Support multiple media items
    let mediaArray = [];
    if (Array.isArray(media)) {
      mediaArray = media;
    } else if (media && typeof media === 'object') {
      mediaArray = [media];
    } else {
      mediaArray = [{ url: 'https://example.com/placeholder.jpg', type: 'image' }];
    }

    const complaint = await Complaint.create({
      title,
      description,
      media: mediaArray,
      location: enrichedLocation,
      citizenId: req.user.id,
      status: 'submitted'
    });
    res.status(201).json(complaint);
  } catch (error) { res.status(400).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/complaints/my:
 *   get:
 *     summary: Get my complaints
 *     tags: [Complaints]
 *     security:
 *       - bearerAuth: []
 */
router.get('/my', protect, async (req, res) => {
  try {
    const complaints = await Complaint.findAll({ 
      where: { citizenId: req.user.id },
      include: [
        { model: User, as: 'citizen', attributes: ['name'] },
        { model: User, as: 'team', attributes: ['name'] }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json(complaints);
  } catch (error) { 
    console.error('Error fetching my complaints:', error);
    res.status(500).json({ error: error.message }); 
  }
});

router.get('/my-team', protect, async (req, res) => {
  try {
    const complaints = await Complaint.findAll({ 
      where: {
        assignedTeamId: req.user.id,
        status: ['team_assigned', 'repair_started']
      },
      include: [
        { model: User, as: 'citizen', attributes: ['name'] },
        { model: User, as: 'team', attributes: ['name'] }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json(complaints);
  } catch (error) {
    console.error('Error fetching team complaints:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/my-team/completed', protect, async (req, res) => {
  try {
    const complaints = await Complaint.findAll({
      where: {
        assignedTeamId: req.user.id,
        status: ['repair_completed', 'verified_closed']
      },
      include: [
        { model: User, as: 'citizen', attributes: ['name'] },
        { model: User, as: 'team', attributes: ['name'] }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json(complaints);
  } catch (error) {
    console.error('Error fetching completed team complaints:', error);
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/complaints/nearby:
 *   get:
 *     summary: Get nearby complaints
 *     tags: [Complaints]
 */
router.get('/nearby', async (req, res) => {
  try {
    const complaints = await Complaint.findAll({ 
      include: [
        { model: User, as: 'citizen', attributes: ['name'] },
        { model: User, as: 'team', attributes: ['name'] }
      ],
      order: [['createdAt', 'DESC']] 
    });
    res.json(complaints);
  } catch (error) { res.status(500).json({ error: error.message }); }
});

/**
 * @swagger
 * /api/complaints/{id}:
 *   get:
 *     summary: Get complaint details
 */
router.get('/:id', async (req, res) => {
  try {
    const complaint = await Complaint.findByPk(req.params.id, { 
      include: [
        { model: User, as: 'citizen', attributes: ['name'] },
        { model: User, as: 'team', attributes: ['name'] }
      ] 
    });
    if (!complaint) return res.status(404).json({ error: 'Not found' });
    res.json(complaint);
  } catch (error) { res.status(400).json({ error: error.message }); }
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
  try {
    await Complaint.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Deleted' });
  } catch (error) { res.status(400).json({ error: error.message }); }
});

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

router.get('/', async (req, res) => {
  try {
    const complaints = await Complaint.findAll({ 
      include: [
        { model: User, as: 'citizen', attributes: ['name'] },
        { model: User, as: 'team', attributes: ['name'] }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json(complaints);
  } catch (error) { 
    console.error('Error fetching complaints:', error);
    res.status(500).json({ error: error.message }); 
  }
});

module.exports = router;
