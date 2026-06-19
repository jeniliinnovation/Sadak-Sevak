const mysql = require('mysql2/promise');
require('dotenv').config();
(async () => {
  try {
    const conn = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
    });

    const [[workRows]] = await conn.query('SELECT COUNT(*) AS cnt FROM information_schema.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?', [process.env.DB_NAME, 'work_orders']);
    const [[authRows]] = await conn.query('SELECT COUNT(*) AS cnt FROM information_schema.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ?', [process.env.DB_NAME, 'auth']);
    console.log('Table work_orders exists:', workRows.cnt > 0, 'auth exists:', authRows.cnt > 0);

    if (workRows.cnt > 0 && authRows.cnt > 0) {
      const [[bad]] = await conn.query('SELECT COUNT(*) AS cnt FROM work_orders WHERE createdById IS NOT NULL AND createdById NOT IN (SELECT id FROM auth)');
      const [[total]] = await conn.query('SELECT COUNT(*) AS cnt FROM work_orders');
      const [[nonNull]] = await conn.query('SELECT COUNT(*) AS cnt FROM work_orders WHERE createdById IS NOT NULL');
      console.log('work_orders total', total.cnt, 'non-null createdById', nonNull.cnt, 'invalid createdById', bad.cnt);
      if (bad.cnt > 0) {
        const [sample] = await conn.query('SELECT id, createdById FROM work_orders WHERE createdById IS NOT NULL AND createdById NOT IN (SELECT id FROM auth) LIMIT 10');
        console.log('Invalid samples:', sample);
      }
    }

    await conn.end();
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
})();
