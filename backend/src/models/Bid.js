const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const User = require('./User');
const Complaint = require('./Complaint');

const Bid = sequelize.define('Bid', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  complaintId: {
    type: DataTypes.CHAR(36),
    allowNull: false,
    references: {
      model: Complaint,
      key: 'id'
    }
  },
  contractorId: {
    type: DataTypes.CHAR(36),
    allowNull: false,
    references: {
      model: User,
      key: 'id'
    }
  },
  cost: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  duration: {
    type: DataTypes.STRING,
    allowNull: false
  },
  message: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('pending', 'approved', 'rejected'),
    defaultValue: 'pending'
  }
}, {
  timestamps: true,
  tableName: 'bids'
});

// Associations
Bid.belongsTo(Complaint, { foreignKey: 'complaintId', as: 'complaint' });
Bid.belongsTo(User, { foreignKey: 'contractorId', as: 'contractor' });

Complaint.hasMany(Bid, { foreignKey: 'complaintId', as: 'bids' });
User.hasMany(Bid, { foreignKey: 'contractorId', as: 'bids' });

module.exports = Bid;
