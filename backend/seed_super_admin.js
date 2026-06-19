const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '.env') });

async function seedSuperAdmin() {
  let connection;
  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME
    });

    const adminUsers = [
      {
        id: 'superadmin',
        name: 'Super Admin',
        email: 'superadmin@citygovernment.gov',
        password: 'superadmin@123',
        role: 'admin'
      },
      {
        id: 'mockadmin',
        name: 'Sadak Admin',
        email: 'admin@sadaksevak.org',
        password: 'admin@123',
        role: 'admin'
      }
    ];

    for (const adminUser of adminUsers) {
      const [rows] = await connection.execute('SELECT * FROM auth WHERE email = ?', [adminUser.email]);
      const hashedPassword = await bcrypt.hash(adminUser.password, 10);

      if (rows.length === 0) {
        console.log(`✓ Creating ${adminUser.name} user...`);
        await connection.execute(
          'INSERT INTO auth (id, name, email, password, role, isVerified, createdAt, updatedAt) VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())',
          [adminUser.id, adminUser.name, adminUser.email, hashedPassword, adminUser.role, true]
        );
        console.log(`✓ ${adminUser.name} created successfully!`);
      } else {
        const existing = rows[0];
        if (existing.id !== adminUser.id) {
          console.log(`⚠️ ${adminUser.name} exists with a different id (${existing.id}). Keeping existing user id for safety.`);
          await connection.execute(
            'UPDATE auth SET name = ?, password = ?, role = ?, isVerified = ?, updatedAt = NOW() WHERE email = ?',
            [adminUser.name, hashedPassword, adminUser.role, true, adminUser.email]
          );
          console.log(`✓ ${adminUser.name} credentials updated`);
        } else {
          await connection.execute(
            'UPDATE auth SET name = ?, password = ?, role = ?, isVerified = ?, updatedAt = NOW() WHERE email = ?',
            [adminUser.name, hashedPassword, adminUser.role, true, adminUser.email]
          );
          console.log(`✓ ${adminUser.name} credentials updated`);
        }
      }
    }

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('📊 SUPER ADMIN / MOCK ADMIN SEED COMPLETE');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

  } catch (error) {
    console.error('❌ Seeding error:', error);
  } finally {
    if (connection) await connection.end();
  }
}

seedSuperAdmin();
