require('dotenv').config({ path: require('path').resolve(__dirname, '.env') });
const mysql = require('mysql2/promise');

(async () => {
  try {
    const conn = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

    console.log('Connected to MySQL, DB:', process.env.DB_NAME);

    const [createRows] = await conn.query("SHOW CREATE TABLE `complaints`");
    if (createRows && createRows.length) {
      console.log('\nSHOW CREATE TABLE `complaints`:\n');
      console.log(createRows[0]['Create Table']);
    } else {
      console.log('No create table row returned.');
    }

    const [fkRows] = await conn.query(
      `SELECT CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
       FROM information_schema.KEY_COLUMN_USAGE
       WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'complaints' AND REFERENCED_TABLE_NAME IS NOT NULL`,
      [process.env.DB_NAME]
    );

    console.log('\nForeign keys on complaints:');
    if (fkRows.length) fkRows.forEach(r => console.log(r)); else console.log('No foreign keys found');

    await conn.end();
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();