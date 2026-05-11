const { sequelize, connectDB } = require('./src/config/db');
const User = require('./src/models/User');
const Complaint = require('./src/models/Complaint');
const bcrypt = require('bcryptjs');

const seedData = async () => {
  try {
    await connectDB();
    await sequelize.sync({ force: true }); // Warning: This will drop tables and recreate them
    console.log('Database synced (force: true).');

    // 1. Create Admin
    const adminPassword = await bcrypt.hash('admin123', 10);
    const admin = await User.create({
      name: 'Site Admin',
      email: 'admin@sadaksevak.com',
      password: adminPassword,
      role: 'admin'
    });
    console.log('Admin user created.');

    // 2. Create Citizen
    const userPassword = await bcrypt.hash('user123', 10);
    const citizen = await User.create({
      name: 'John Citizen',
      email: 'john@gmail.com',
      password: userPassword,
      role: 'citizen'
    });
    console.log('Citizen user created.');

    // 3. Create a Complaint
    await Complaint.create({
      title: 'Huge Pothole near Central Mall',
      description: 'There is a massive pothole that is causing accidents at night.',
      media: {
        url: 'https://res.cloudinary.com/demo/image/upload/v1631234567/pothole.jpg',
        type: 'image'
      },
      location: {
        type: 'Point',
        coordinates: [72.8777, 19.0760],
        address: 'MG Road, near Central Mall',
        area: 'Worli',
        zone: 'South'
      },
      citizenId: citizen.id,
      status: 'submitted'
    });
    console.log('Seed complaint created.');

    process.exit(0);
  } catch (error) {
    console.error('Error seeding data:', error);
    process.exit(1);
  }
};

seedData();
