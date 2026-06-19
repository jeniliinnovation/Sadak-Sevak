const express = require('express');
const router = express.Router();
const Bid = require('../models/Bid');
const Complaint = require('../models/Complaint');
const User = require('../models/User');
const { protect, authorize } = require('../middleware/auth');

/**
 * @swagger
 * /api/bids:
 *   post:
 *     summary: Submit or update a repair offer (bid) for a complaint
 *     tags: [Bids]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [complaintId, cost, duration, message]
 *             properties:
 *               complaintId: { type: string, example: "complaint-uuid" }
 *               cost: { type: number, example: 45000 }
 *               duration: { type: string, example: "5 Days" }
 *               message: { type: string, example: "Proposal details..." }
 */
router.post('/', protect, authorize('contractor', 'admin'), async (req, res) => {
  console.log('POST /api/bids reached. User:', req.user ? { id: req.user.id, role: req.user.role } : 'none');
  try {
    const { complaintId, cost, duration, message } = req.body;

    const complaint = await Complaint.findByPk(complaintId);
    if (!complaint) {
      return res.status(404).json({ error: 'Complaint not found' });
    }

    // Check if contractor already submitted a bid for this complaint
    const existingBid = await Bid.findOne({
      where: {
        complaintId,
        contractorId: req.user.id
      }
    });

    if (existingBid) {
      existingBid.cost = cost;
      existingBid.duration = duration;
      existingBid.message = message;
      await existingBid.save();
      return res.json(existingBid);
    }

    const bid = await Bid.create({
      complaintId,
      contractorId: req.user.id,
      cost,
      duration,
      message
    });

    res.status(201).json(bid);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/bids/my:
 *   get:
 *     summary: Get bids submitted by current logged-in contractor
 *     tags: [Bids]
 *     security:
 *       - bearerAuth: []
 */
router.get('/my', protect, authorize('contractor', 'admin'), async (req, res) => {
  console.log('GET /api/bids/my reached. User:', req.user ? { id: req.user.id, role: req.user.role } : 'none');
  try {
    const bids = await Bid.findAll({
      where: { contractorId: req.user.id },
      include: [
        { model: Complaint, as: 'complaint' }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json(bids);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/bids/complaint/{complaintId}:
 *   get:
 *     summary: Get bids submitted for a specific complaint
 *     tags: [Bids]
 *     security:
 *       - bearerAuth: []
 */
router.get('/complaint/:complaintId', protect, async (req, res) => {
  console.log('GET /api/bids/complaint/:complaintId reached. User:', req.user ? { id: req.user.id, role: req.user.role } : 'none');
  try {
    const bids = await Bid.findAll({
      where: { complaintId: req.params.complaintId },
      include: [
        { model: User, as: 'contractor', attributes: ['id', 'name', 'email'] }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json(bids);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @swagger
 * /api/bids:
 *   get:
 *     summary: Get all bids (admin/government only)
 *     tags: [Bids]
 *     security:
 *       - bearerAuth: []
 */
router.get('/', protect, authorize('admin', 'department_head', 'government'), async (req, res) => {
  console.log('GET /api/bids reached. User:', req.user ? { id: req.user.id, role: req.user.role } : 'none');
  try {
    const bids = await Bid.findAll({
      include: [
        { model: Complaint, as: 'complaint' },
        { model: User, as: 'contractor', attributes: ['id', 'name', 'email'] }
      ],
      order: [['createdAt', 'DESC']]
    });
    res.json(bids);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const { Op } = require('sequelize');
const WorkOrder = require('../models/WorkOrder');

router.put('/:id/approve', protect, authorize('admin', 'department_head', 'government'), async (req, res) => {
  try {
    const bid = await Bid.findByPk(req.params.id);
    if (!bid) {
      return res.status(404).json({ error: 'Bid not found' });
    }

    bid.status = 'approved';
    await bid.save();

    // Reject other bids for the same complaint
    await Bid.update(
      { status: 'rejected' },
      { 
        where: { 
          complaintId: bid.complaintId, 
          id: { [Op.ne]: bid.id } 
        } 
      }
    );

    // Update complaint status to team_assigned
    const complaint = await Complaint.findByPk(bid.complaintId);
    if (complaint) {
      complaint.status = 'team_assigned';
      await complaint.save();

      // Create a work order automatically for this contractor
      await WorkOrder.create({
        complaintId: bid.complaintId,
        title: `Repair Work: ${complaint.title}`,
        description: `Approved Contractor Proposal Details: ${bid.message}`,
        workType: 'Pothole Repair',
        location: complaint.location,
        contractorId: bid.contractorId,
        priority: complaint.priority || 'Medium',
        status: 'pending',
        budget: bid.cost,
        estimatedDuration: parseInt(bid.duration) || 7
      });
    }

    res.json({ message: 'Bid approved and work order initialized', bid });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

router.put('/:id/reject', protect, authorize('admin', 'department_head', 'government'), async (req, res) => {
  try {
    const bid = await Bid.findByPk(req.params.id);
    if (!bid) {
      return res.status(404).json({ error: 'Bid not found' });
    }

    bid.status = 'rejected';
    await bid.save();

    res.json({ message: 'Bid rejected successfully', bid });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

module.exports = router;
