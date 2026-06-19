const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Contractor = sequelize.define('Contractor', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  companyName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  specialization: {
    type: DataTypes.STRING // e.g., 'Pothole Repair', 'Water Logging'
  },
  rating: {
    type: DataTypes.FLOAT,
    defaultValue: 5.0
  },
  status: {
    type: DataTypes.ENUM('pending', 'approved', 'rejected'),
    defaultValue: 'pending'
  },
  rejectionReason: {
    type: DataTypes.STRING,
    allowNull: true
  },
  contactPerson: {
    type: DataTypes.STRING,
    allowNull: true
  },
  phone: {
    type: DataTypes.STRING,
    allowNull: true
  },
  userId: {
    type: DataTypes.CHAR(36),
    allowNull: true
  }
}, {
  timestamps: true,
  tableName: 'contractors'
});


module.exports = Contractor;
