const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const User = require('./User');
const Complaint = require('./Complaint');

const Like = sequelize.define('Like', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  userId: {
    type: DataTypes.CHAR(36),
    allowNull: false,
    references: { model: User, key: 'id' }
  },
  complaintId: {
    type: DataTypes.CHAR(36),
    allowNull: false,
    references: { model: Complaint, key: 'id' }
  }
}, { 
  timestamps: true,
  tableName: 'likes'
});

const Confirmation = sequelize.define('Confirmation', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  userId: {
    type: DataTypes.CHAR(36),
    allowNull: false,
    references: { model: User, key: 'id' }
  },
  complaintId: {
    type: DataTypes.CHAR(36),
    allowNull: false,
    references: { model: Complaint, key: 'id' }
  }
}, { 
  timestamps: true,
  tableName: 'confirmations'
});



// Associations
Like.belongsTo(User, { foreignKey: 'userId' });
Like.belongsTo(Complaint, { foreignKey: 'complaintId' });
Confirmation.belongsTo(User, { foreignKey: 'userId' });
Confirmation.belongsTo(Complaint, { foreignKey: 'complaintId' });

User.hasMany(Like, { foreignKey: 'userId' });
User.hasMany(Confirmation, { foreignKey: 'userId' });
Complaint.hasMany(Like, { foreignKey: 'complaintId' });
Complaint.hasMany(Confirmation, { foreignKey: 'complaintId' });

module.exports = { Like, Confirmation };
