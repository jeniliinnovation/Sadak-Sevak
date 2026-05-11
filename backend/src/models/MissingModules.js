const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const MediaUpload = sequelize.define('MediaUpload', {
  id: { type: DataTypes.CHAR(36), defaultValue: DataTypes.UUIDV4, primaryKey: true },
  url: { type: DataTypes.STRING },
  type: { type: DataTypes.STRING }
}, { tableName: 'Media_Upload' });

const LiveMap = sequelize.define('LiveMap', {
  id: { type: DataTypes.CHAR(36), defaultValue: DataTypes.UUIDV4, primaryKey: true },
  zoomLevel: { type: DataTypes.INTEGER, defaultValue: 10 },
  centerLat: { type: DataTypes.FLOAT },
  centerLng: { type: DataTypes.FLOAT }
}, { tableName: 'Live_Map' });

const Analytics = sequelize.define('Analytics', {
  id: { type: DataTypes.CHAR(36), defaultValue: DataTypes.UUIDV4, primaryKey: true },
  metricName: { type: DataTypes.STRING },
  metricValue: { type: DataTypes.FLOAT }
}, { tableName: 'Analytics' });

module.exports = { MediaUpload, LiveMap, Analytics };
