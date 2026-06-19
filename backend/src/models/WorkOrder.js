const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const User = require('./User');
const Complaint = require('./Complaint');

const WorkOrder = sequelize.define('WorkOrder', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  complaintId: {
    type: DataTypes.CHAR(36),
    allowNull: true,
    references: {
      model: Complaint,
      key: 'id'
    }
  },
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  description: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  workType: {
    type: DataTypes.ENUM('Pothole Repair', 'Drainage Cleaning', 'Street Light Installation', 'Road Resurfacing', 'Maintenance', 'Inspection'),
    defaultValue: 'Maintenance'
  },
  location: {
    type: DataTypes.JSON,
    allowNull: false
  },
  assignedToId: {
    type: DataTypes.CHAR(36),
    allowNull: true,
    references: {
      model: User,
      key: 'id'
    }
  },
  contractorId: {
    type: DataTypes.CHAR(36),
    allowNull: true
  },
  priority: {
    type: DataTypes.ENUM('Low', 'Medium', 'High', 'Critical'),
    defaultValue: 'Medium'
  },
  status: {
    type: DataTypes.ENUM('pending', 'in_progress', 'on_hold', 'completed', 'cancelled'),
    defaultValue: 'pending'
  },
  progress: {
    type: DataTypes.INTEGER,
    defaultValue: 0,
    validate: { min: 0, max: 100 }
  },
  startDate: {
    type: DataTypes.DATE,
    allowNull: true
  },
  endDate: {
    type: DataTypes.DATE,
    allowNull: true
  },
  budget: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true
  },
  estimatedDuration: {
    type: DataTypes.INTEGER,
    allowNull: true,
    comment: 'Duration in days'
  },
  notes: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  createdById: {
    type: DataTypes.CHAR(36),
    allowNull: true,
    references: {
      model: User,
      key: 'id'
    }
  }
}, {
  timestamps: true,
  tableName: 'work_orders'
});

// Define associations
WorkOrder.belongsTo(User, { foreignKey: 'assignedToId', as: 'assignedTo' });
WorkOrder.belongsTo(User, { foreignKey: 'createdById', as: 'createdBy' });
WorkOrder.belongsTo(Complaint, { foreignKey: 'complaintId', as: 'complaint' });

module.exports = WorkOrder;
