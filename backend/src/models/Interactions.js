const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const User = require('./User');
const Complaint = require('./Complaint');

const Like = sequelize.define('Like', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  }
}, { timestamps: true });

const Confirmation = sequelize.define('Confirmation', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  }
}, { 
  timestamps: true,
  tableName: 'Community_Interactions'
});

// Associations
Like.belongsTo(User);
Like.belongsTo(Complaint);
Confirmation.belongsTo(User);
Confirmation.belongsTo(Complaint);

User.hasMany(Like);
User.hasMany(Confirmation);
Complaint.hasMany(Like);
Complaint.hasMany(Confirmation);

module.exports = { Like, Confirmation };
