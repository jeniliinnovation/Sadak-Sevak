const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const User = require('./User');

const Complaint = sequelize.define('Complaint', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  media: {
    type: DataTypes.JSON, // { url, public_id, type }
    allowNull: false
  },
  category: {
    type: DataTypes.STRING,
    defaultValue: 'General'
  },
  priority: {
    type: DataTypes.ENUM('Low', 'Medium', 'High', 'Critical'),
    defaultValue: 'Medium'
  },
  location: {
    type: DataTypes.JSON, // { type, coordinates, address, area, zone }
    allowNull: false
  },
  // We'll use foreign keys for citizen and assignedTeam
  citizenId: {
    type: DataTypes.CHAR(36),
    allowNull: false,
    references: {
      model: User,
      key: 'id'
    }
  },
  department: {
    type: DataTypes.STRING,
    allowNull: true
  },
  assignedTeamId: {
    type: DataTypes.CHAR(36),
    allowNull: true,
    references: {
      model: User,
      key: 'id'
    }
  },
  aiResults: {
    type: DataTypes.JSON, // { roadHealthScore, riskLevel, severity, detections }
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM(
      'submitted', 'under_review', 'pending', 'escalated', 
      'team_assigned', 'repair_started', 'repair_completed', 
      'verified_closed', 'reopened'
    ),
    defaultValue: 'submitted'
  },
  repairProof: {
    type: DataTypes.JSON, // { mediaUrl, completionNotes, completedAt }
    allowNull: true
  },
  likesCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  likes: {
    type: DataTypes.JSON, // Array of user IDs
    defaultValue: []
  },
  confirmationCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  escalationLevel: {
    type: DataTypes.INTEGER,
    defaultValue: 1
  },
  lastStatusUpdate: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW
  },
  deadline: {
    type: DataTypes.DATE,
    allowNull: true
  }
}, {
  timestamps: true,
  tableName: 'complaints'
});


// Associations
Complaint.belongsTo(User, { as: 'citizen', foreignKey: 'citizenId' });
Complaint.belongsTo(User, { as: 'team', foreignKey: 'assignedTeamId' });

module.exports = Complaint;
