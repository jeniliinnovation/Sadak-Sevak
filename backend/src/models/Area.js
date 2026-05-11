const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const Area = sequelize.define('Area', {
  id: {
    type: DataTypes.CHAR(36),
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true
  },
  zoneName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  wardName: {
    type: DataTypes.STRING,
    allowNull: false
  },
  latMin: {
    type: DataTypes.FLOAT,
    allowNull: false
  },
  latMax: {
    type: DataTypes.FLOAT,
    allowNull: false
  },
  lngMin: {
    type: DataTypes.FLOAT,
    allowNull: false
  },
  lngMax: {
    type: DataTypes.FLOAT,
    allowNull: false
  },
  isActive: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  timestamps: true,
  tableName: 'areas'
});

module.exports = Area;
