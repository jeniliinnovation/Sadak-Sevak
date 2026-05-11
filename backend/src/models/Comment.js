const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/db');
const User = require('./User');
const Complaint = require('./Complaint');

const Comment = sequelize.define('Comment', {
  id: { type: DataTypes.CHAR(36), defaultValue: DataTypes.UUIDV4, primaryKey: true },
  content: { type: DataTypes.TEXT, allowNull: false },
  userId: { type: DataTypes.CHAR(36), allowNull: false, references: { model: User, key: 'id' } },
  complaintId: { type: DataTypes.CHAR(36), allowNull: false, references: { model: Complaint, key: 'id' } }
}, { 
  timestamps: true,
  tableName: 'comments'
});

Comment.belongsTo(User, { foreignKey: 'userId' });
Comment.belongsTo(Complaint, { foreignKey: 'complaintId' });
Complaint.hasMany(Comment, { foreignKey: 'complaintId' });

module.exports = Comment;
