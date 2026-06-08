const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

async function seedGovernmentUser() {
  let connection;
  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME
    });

    const users = [
      { name: 'Admin User', email: 'admin@sadaksevak.com', pass: 'admin123', role: 'admin' },
      { name: 'Priya Mehta', email: 'priya.mehta@gov.in', pass: 'gov123', role: 'team_member' },
      { name: 'Ravi Kumar', email: 'ravi.kumar@gov.in', pass: 'gov123', role: 'government' },
    ];

    for (const u of users) {
      const [rows] = await connection.execute('SELECT * FROM auth WHERE email = ?', [u.email]);
      if (rows.length === 0) {
        console.log(`Creating user: ${u.email}`);
        const hashedPassword = await bcrypt.hash(u.pass, 10);
        const userId = require('crypto').randomUUID();
        await connection.execute(
          'INSERT INTO auth (id, name, email, password, role, isVerified, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())',
          [userId, u.name, u.email, hashedPassword, u.role, true]
        );
      } else {
        console.log(`User exists: ${u.email}`);
        await connection.execute('UPDATE auth SET role = ? WHERE email = ?', [u.role, u.email]);
      }
    }

  } catch (error) {
    console.error('Seeding error:', error);
  } finally {
    if (connection) await connection.end();
  }
}

seedGovernmentUser();
