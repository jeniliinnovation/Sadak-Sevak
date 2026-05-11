const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const Complaint = require('./Complaint');

const AIResult = sequelize.define('AIResult', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  roadHealthScore: { type: DataTypes.INTEGER },
  riskLevel: { type: DataTypes.STRING },
  damageType: { type: DataTypes.STRING },
  confidence: { type: DataTypes.FLOAT },
  complaintId: {
    type: DataTypes.CHAR(36),
    allowNull: false,
    references: {
      model: Complaint,
      key: 'id'
    }
  }
}, { 
  timestamps: true,
  tableName: 'ai_analysis'
});

AIResult.belongsTo(Complaint, { foreignKey: 'complaintId' });
Complaint.hasOne(AIResult, { foreignKey: 'complaintId' });

module.exports = AIResult;
