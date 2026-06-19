const mysql = require('mysql2/promise');
const dotenv = require('dotenv');
const path = require('path');

dotenv.config({ path: path.join(__dirname, '..', '.env') });

(async () => {
  try {
    const conn = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

    const [rows] = await conn.query(
      "SELECT id, email, role, password IS NOT NULL AS hasPassword, createdAt, updatedAt FROM auth WHERE role = 'contractor' OR email = 'rajesh.contractor@builder.in'"
    );

    console.log('Contractor auth rows:');
    console.table(rows);
    await conn.end();
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
