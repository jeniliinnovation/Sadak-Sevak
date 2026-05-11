const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const Complaint = require('./Complaint');

const EscalationLog = sequelize.define('EscalationLog', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  previousLevel: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  newLevel: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  reason: {
    type: DataTypes.STRING
  },
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
  tableName: 'Escalation'
});

EscalationLog.belongsTo(Complaint, { foreignKey: 'complaintId' });
Complaint.hasMany(EscalationLog, { foreignKey: 'complaintId' });

module.exports = EscalationLog;
