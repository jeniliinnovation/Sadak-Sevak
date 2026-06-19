require('dotenv').config();
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
(async ()=>{
  try{
    const conn = await mysql.createConnection({
      host: process.env.DB_HOST,
      port: process.env.DB_PORT,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME
    });
    const [rows] = await conn.query("SELECT password FROM auth WHERE email = 'rajesh.contractor@builder.in'");
    if(rows.length===0){ console.log('no user'); return; }
    const hash = rows[0].password;
    const match = await bcrypt.compare('contract123', hash);
    console.log('bcrypt compare result:', match);
    await conn.end();
  }catch(err){console.error(err);}
})();