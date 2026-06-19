const { sequelize, connectDB } = require('./src/config/db');
const User = require('./src/models/User');

(async () => {
  try {
    await connectDB();
    const users = await User.findAll({ attributes: ['id','email','role','password'] });
    if (!users || users.length === 0) {
      console.log('No users found');
    } else {
      console.log('Users:');
      users.forEach(u => console.log(u.email, '|', u.role, '|', u.password ? 'has-password' : 'no-password'));
    }
  } catch (err) {
    console.error(err);
  } finally {
    await sequelize.close();
    process.exit();
  }
})();