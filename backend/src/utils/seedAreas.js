const Area = require('../models/Area');
const { connectDB, sequelize } = require('../config/db');

const seedData = [
  { zoneName: 'North Zone', wardName: 'Ward 1', latMin: 19.2, latMax: 19.3, lngMin: 72.8, lngMax: 72.9 },
  { zoneName: 'North Zone', wardName: 'Ward 2', latMin: 19.2, latMax: 19.3, lngMin: 72.8, lngMax: 72.9 },
  { zoneName: 'South Zone', wardName: 'Ward 4', latMin: 18.9, latMax: 19.0, lngMin: 72.8, lngMax: 72.9 },
  { zoneName: 'East Zone', wardName: 'Ward 7', latMin: 19.0, latMax: 19.1, lngMin: 72.9, lngMax: 73.0 },
  { zoneName: 'West Zone', wardName: 'Ward 10', latMin: 19.1, latMax: 19.2, lngMin: 72.8, lngMax: 72.9 }
];

const runSeed = async () => {
  try {
    await connectDB();
    await sequelize.sync();
    
    // Clear existing
    await Area.destroy({ where: {}, truncate: true });
    
    // Bulk create
    await Area.bulkCreate(seedData);
    
    console.log('SARA Areas seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding areas:', error);
    process.exit(1);
  }
};

runSeed();
