const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'mysql',
    logging: false,
    pool: {
      max: 5,
      min: 0,
      acquire: 30000,
      idle: 10000
    }
  }
);

const mysql = require('mysql2/promise');

const connectDB = async () => {
  try {
    // 1. Ensure database exists
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
    });
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${process.env.DB_NAME}\`;`);
    await connection.end();

    // 2. Connect with Sequelize
    await sequelize.authenticate();
    console.log('MySQL connected successfully.');

    // Dynamically ensure status column exists in MySQL table
    try {
      await sequelize.query("ALTER TABLE bids ADD COLUMN status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending'");
      console.log('Successfully ensured status column exists in bids table.');
    } catch (err) {
      // Ignored if column already exists
    }
  } catch (error) {
    console.error('Unable to connect to the database:', error);
    process.exit(1);
  }
};

module.exports = { sequelize, connectDB };
