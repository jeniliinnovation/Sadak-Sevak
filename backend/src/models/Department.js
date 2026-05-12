const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Department = sequelize.define('Department', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  name: {
    type: DataTypes.STRING,
    allowNull: false,
    unique: true
  },
  headName: {
    type: DataTypes.STRING
  },
  contactEmail: {
    type: DataTypes.STRING
  }
}, {
  timestamps: true,
  tableName: 'departments'
});

module.exports = Department;
