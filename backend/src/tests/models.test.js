const { sequelize } = require('../config/db');
// Import all models to ensure they are registered
const User = require('../models/User');
const Complaint = require('../models/Complaint');
const Area = require('../models/Area');
const Comment = require('../models/Comment');
const { Like, Confirmation } = require('../models/Interactions');
const Contractor = require('../models/Contractor');
const Department = require('../models/Department');
const Notification = require('../models/Notification');
const AIResult = require('../models/AIResult');

describe('Database Models Test', () => {
  beforeAll(async () => {
    try {
      await sequelize.query('SET FOREIGN_KEY_CHECKS = 0');
      
      const [tables] = await sequelize.query("SHOW TABLES");
      const dbName = sequelize.config.database;
      for (const tableObj of tables) {
        const tableName = tableObj[`Tables_in_${dbName}`];
        await sequelize.query(`DROP TABLE IF EXISTS \`${tableName}\``);
      }
      
      await sequelize.sync({ force: true });
      await sequelize.query('SET FOREIGN_KEY_CHECKS = 1');
    } catch (error) {
      console.error('Error during setup:', error);
      throw error;
    }
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('should create and link data correctly', async () => {
    // 1. Create User
    const user = await User.create({
      name: 'Test Citizen',
      email: `test_${Date.now()}@example.com`,
      password: 'password123'
    });
    expect(user.id).toBeDefined();

    // 2. Create Area
    const area = await Area.create({
      zoneName: 'Central',
      wardName: 'W1',
      latMin: 0, latMax: 1, lngMin: 0, lngMax: 1
    });
    expect(area.id).toBeDefined();

    // 3. Create Complaint
    const complaint = await Complaint.create({
      title: 'Pothole',
      description: 'Big one',
      media: { url: 'img.png' },
      location: { lat: 0.5, lng: 0.5, area: 'Central' },
      citizenId: user.id
    });
    expect(complaint.id).toBeDefined();

    // 4. Create Interaction
    const like = await Like.create({
      userId: user.id,
      complaintId: complaint.id
    });
    expect(like.userId).toBe(user.id);
  });
});
