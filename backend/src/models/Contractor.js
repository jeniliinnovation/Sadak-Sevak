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
  }
}, {
  timestamps: true
});

module.exports = Contractor;
