const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const GovernmentAdmin = sequelize.define('GovernmentAdmin', {
  id: { type: DataTypes.CHAR(36), defaultValue: DataTypes.UUIDV4, primaryKey: true },
  deptName: { type: DataTypes.STRING },
  headName: { type: DataTypes.STRING },
  contactEmail: { type: DataTypes.STRING }
}, { tableName: 'government_admin', timestamps: true });

const RolesLegend = sequelize.define('RolesLegend', {
  id: { type: DataTypes.CHAR(36), defaultValue: DataTypes.UUIDV4, primaryKey: true },
  roleSymbol: { type: DataTypes.STRING }, // P, C, R, G, A
  meaning: { type: DataTypes.STRING }
}, { tableName: 'roles_legend', timestamps: false });

const SummaryTable = sequelize.define('SummaryTable', {
  id: { type: DataTypes.CHAR(36), defaultValue: DataTypes.UUIDV4, primaryKey: true },
  reportDate: { type: DataTypes.DATEONLY },
  totalComplaints: { type: DataTypes.INTEGER },
  resolvedComplaints: { type: DataTypes.INTEGER }
}, { tableName: 'summary_table', timestamps: true });

module.exports = { GovernmentAdmin, RolesLegend, SummaryTable };
