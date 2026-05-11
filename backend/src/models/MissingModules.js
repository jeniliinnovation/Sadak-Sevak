const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');

const MediaUpload = sequelize.define('MediaUpload', {
  id: { type: DataTypes.CHAR(36), defaultValue: DataTypes.UUIDV4, primaryKey: true },
  url: { type: DataTypes.STRING },
  type: { type: DataTypes.STRING }
}, { tableName: 'media_upload' });

const LiveMap = sequelize.define('LiveMap', {
  id: { type: DataTypes.CHAR(36), defaultValue: DataTypes.UUIDV4, primaryKey: true },
  zoomLevel: { type: DataTypes.INTEGER, defaultValue: 10 },
  centerLat: { type: DataTypes.FLOAT },
  centerLng: { type: DataTypes.FLOAT }
}, { tableName: 'live_map' });

const Analytics = sequelize.define('Analytics', {
  id: { type: DataTypes.CHAR(36), defaultValue: DataTypes.UUIDV4, primaryKey: true },
  metricName: { type: DataTypes.STRING },
  metricValue: { type: DataTypes.FLOAT }
}, { tableName: 'analytics' });


module.exports = { MediaUpload, LiveMap, Analytics };
