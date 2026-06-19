const express = require('express');
const router = express.Router();
const Complaint = require('../models/Complaint');
const { Analytics } = require('../models/MissingModules');
const { protect, authorize } = require('../middleware/auth');
const { sequelize } = require('../config/db');

/**
 * @swagger
 * /api/analytics/metrics:
 *   get:
 *     summary: Get all system metrics
 *     tags: [Analytics]
 *     responses:
 *       200:
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items: { type: object }
 */
router.get('/metrics', async (req, res) => {
  const data = await Analytics.findAll();
  res.json(data);
});

/**
 * @swagger
 * /api/analytics/complaints:
 *   get:
 *     summary: Trend Chart Data (Complaint status counts)
 *     tags: [Analytics]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: array
 *               items: { type: object }
 */
router.get('/complaints', protect, authorize('admin'), async (req, res) => {
  const stats = await Complaint.count({
    attributes: ['status'],
    group: 'status'
  });
  res.json(stats);
});

/**
 * @swagger
 * /api/analytics/zones:
 *   get:
 *     summary: Get zone-wise status
 *     tags: [Analytics]
 *     responses:
 *       200: { description: OK }
 */
router.get('/zones', async (req, res) => { 
  res.json([]); 
});

/**
 * @swagger
 * /api/analytics/repairs:
 *   get:
 *     summary: Get repair completion analytics
 *     tags: [Analytics]
 *     responses:
 *       200:
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 total: { type: number, example: 150 }
 *                 completed: { type: number, example: 125 }
 *                 rate: { type: string, example: "83%" }
 *                 avgTimeDays: { type: number, example: 4.5 }
 */
router.get('/repairs', (req, res) => { 
  res.json({ 
    total: 150, 
    completed: 125, 
    rate: '83%',
    avgTimeDays: 4.5
  }); 
});

/**
 * @swagger
 * /api/analytics/ai-accuracy:
 *   get:
 *     summary: Get AI classification accuracy metrics
 *     tags: [Analytics]
 *     responses:
 *       200:
 *         description: OK
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 overall: { type: string, example: "94.2%" }
 *                 potholeDetection: { type: string, example: "96.5%" }
 *                 severityScoring: { type: string, example: "91.8%" }
 */
router.get('/ai-accuracy', (req, res) => { 
  res.json({ 
    overall: '94.2%', 
    potholeDetection: '96.5%', 
    severityScoring: '91.8%' 
  }); 
});

router.get('/stats', async (req, res) => {
  try {
    const metrics = await Analytics.findAll();
    const repairs = {
      total: 150,
      completed: 125,
      rate: '83%',
      avgTimeDays: 4.5,
    };
    const aiAccuracy = {
      overall: '94.2%',
      potholeDetection: '96.5%',
      severityScoring: '91.8%',
    };

    // Calculate SARA coverage by zone from actual complaint data
    let saraCoverage = [];
    try {
      const allComplaints = await Complaint.findAll({
        attributes: ['id', 'location', 'status'],
        raw: true,
      });

      // Group complaints by zone and calculate resolution rate
      const zoneMap = {};
      allComplaints.forEach((complaint) => {
        try {
          const location = typeof complaint.location === 'string' 
            ? JSON.parse(complaint.location) 
            : complaint.location;
          
          const zone = location?.area || 'Unknown Zone';
          
          if (!zoneMap[zone]) {
            zoneMap[zone] = { total: 0, resolved: 0 };
          }
          
          zoneMap[zone].total += 1;
          // Count as resolved if status indicates completion
          if (complaint.status === 'repair_completed' || complaint.status === 'verified_closed') {
            zoneMap[zone].resolved += 1;
          }
        } catch (e) {
          // skip malformed location
        }
      });

      saraCoverage = Object.entries(zoneMap).map(([zone, stats]) => ({
        label: zone,
        value: stats.total > 0 ? Math.round((stats.resolved / stats.total) * 100) : 0,
      }));
    } catch (e) {
      console.error('Error calculating zone coverage:', e);
    }

    // Fallback to mock data if no zones found
    if (saraCoverage.length === 0) {
      saraCoverage = [
        { label: 'Zone 1', value: 85 },
        { label: 'Zone 2', value: 72 },
        { label: 'Zone 3', value: 68 }
      ];
    }

    const statusCounts = await Complaint.findAll({
      attributes: ['status', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
      group: ['status'],
    });
    const categoryCounts = await Complaint.findAll({
      attributes: ['category', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
      group: ['category'],
    });

    const complaintsTrend = {
      labels: statusCounts.map((item) => item.status),
      data: statusCounts.map((item) => Number(item.get('count'))),
    };

    const categoryBreakdown = {
      labels: categoryCounts.map((item) => item.category),
      data: categoryCounts.map((item) => Number(item.get('count'))),
    };

    // Calculate resolved/pending counts from actual statuses
    const completedCount = statusCounts
      .filter(item => item.status === 'repair_completed' || item.status === 'verified_closed')
      .reduce((sum, item) => sum + Number(item.get('count')), 0);
    const pendingCount = statusCounts
      .filter(item => item.status === 'submitted' || item.status === 'pending' || item.status === 'team_assigned' || item.status === 'repair_started')
      .reduce((sum, item) => sum + Number(item.get('count')), 0);

    res.json({
      metrics,
      repairs,
      aiAccuracy,
      zones: saraCoverage,
      complaintsTrend,
      categoryBreakdown,
      saraCoverage,
      stats: {
        totalComplaints: statusCounts.reduce((sum, item) => sum + Number(item.get('count')), 0),
        resolved: completedCount,
        pending: pendingCount,
        rejected: 0,
      },
    });
  } catch (error) {
    console.error('Analytics stats error:', error);
    res.status(500).json({ error: error.message });
  }
});


router.get('/', async (req, res) => {
  try {
    const metrics = await Analytics.findAll();
    const repairs = {
      total: 150,
      completed: 125,
      rate: '83%',
      avgTimeDays: 4.5,
    };
    const aiAccuracy = {
      overall: '94.2%',
      potholeDetection: '96.5%',
      severityScoring: '91.8%',
    };

    // Calculate SARA coverage by zone from actual complaint data
    let saraCoverage = [];
    try {
      const allComplaints = await Complaint.findAll({
        attributes: ['id', 'location', 'status'],
        raw: true,
      });

      // Group complaints by zone and calculate resolution rate
      const zoneMap = {};
      allComplaints.forEach((complaint) => {
        try {
          const location = typeof complaint.location === 'string' 
            ? JSON.parse(complaint.location) 
            : complaint.location;
          
          const zone = location?.area || 'Unknown Zone';
          
          if (!zoneMap[zone]) {
            zoneMap[zone] = { total: 0, resolved: 0 };
          }
          
          zoneMap[zone].total += 1;
          // Count as resolved if status indicates completion
          if (complaint.status === 'repair_completed' || complaint.status === 'verified_closed') {
            zoneMap[zone].resolved += 1;
          }
        } catch (e) {
          // skip malformed location
        }
      });

      saraCoverage = Object.entries(zoneMap).map(([zone, stats]) => ({
        label: zone,
        value: stats.total > 0 ? Math.round((stats.resolved / stats.total) * 100) : 0,
      }));
    } catch (e) {
      console.error('Error calculating zone coverage:', e);
    }

    // Fallback to mock data if no zones found
    if (saraCoverage.length === 0) {
      saraCoverage = [
        { label: 'Zone 1', value: 85 },
        { label: 'Zone 2', value: 72 },
        { label: 'Zone 3', value: 68 }
      ];
    }

    const statusCounts = await Complaint.findAll({
      attributes: ['status', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
      group: ['status'],
    });
    const categoryCounts = await Complaint.findAll({
      attributes: ['category', [sequelize.fn('COUNT', sequelize.col('id')), 'count']],
      group: ['category'],
    });

    const complaintsTrend = {
      labels: statusCounts.map((item) => item.status),
      data: statusCounts.map((item) => Number(item.get('count'))),
    };

    const categoryBreakdown = {
      labels: categoryCounts.map((item) => item.category),
      data: categoryCounts.map((item) => Number(item.get('count'))),
    };

    // Calculate resolved/pending counts from actual statuses
    const completedCount = statusCounts
      .filter(item => item.status === 'repair_completed' || item.status === 'verified_closed')
      .reduce((sum, item) => sum + Number(item.get('count')), 0);
    const pendingCount = statusCounts
      .filter(item => item.status === 'submitted' || item.status === 'pending' || item.status === 'team_assigned' || item.status === 'repair_started')
      .reduce((sum, item) => sum + Number(item.get('count')), 0);

    res.json({
      metrics,
      repairs,
      aiAccuracy,
      zones: saraCoverage,
      complaintsTrend,
      categoryBreakdown,
      saraCoverage,
      stats: {
        totalComplaints: statusCounts.reduce((sum, item) => sum + Number(item.get('count')), 0),
        resolved: completedCount,
        pending: pendingCount,
        rejected: 0,
      },
    });
  } catch (error) {
    console.error('Analytics error:', error);
    res.status(500).json({ error: error.message });
  }
});


module.exports = router;
