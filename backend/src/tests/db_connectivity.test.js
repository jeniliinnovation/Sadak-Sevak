const { sequelize } = require('../config/db');
const User = require('../models/User');

describe('Database Connectivity Test', () => {
  beforeAll(async () => {
    // Ensure we are connected
    await sequelize.authenticate();
  });

  afterAll(async () => {
    await sequelize.close();
  });

  it('should be able to create and delete a temporary test user', async () => {
    const testEmail = `connection_test_${Date.now()}@example.com`;
    
    // Create
    const user = await User.create({
      name: 'DB Connectivity Test User',
      email: testEmail,
      password: 'testPassword123'
    });
    
    expect(user.id).toBeDefined();
    expect(user.email).toBe(testEmail);
    
    // Cleanup - Delete
    await user.destroy();
    
    // Verify deleted
    const foundUser = await User.findOne({ where: { email: testEmail } });
    expect(foundUser).toBeNull();
  });
});
