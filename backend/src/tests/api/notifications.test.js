const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');
const Notification = require('../../models/Notification');

describe('Notifications API Functional Tests', () => {
  let citizenToken;
  let citizenId;
  let notificationId;

  beforeAll(async () => {
    await setupTestDB();

    // Create Citizen
    const citizenRes = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Citizen',
        email: 'citizen@example.com',
        password: 'password123',
        role: 'citizen'
      });
    citizenId = citizenRes.body.id;
    
    const citizenLoginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'citizen@example.com',
        password: 'password123'
      });
    citizenToken = citizenLoginRes.body.token;

    // Create a mock notification
    const notification = await Notification.create({
      title: 'Welcome',
      message: 'Welcome to Sadak-Sevak',
      userId: citizenId
    });
    notificationId = notification.id;
  });

  afterAll(async () => {
    await closeTestDB();
  });

  it('GET /api/notifications - should return notifications for user', async () => {
    const res = await request(app)
      .get('/api/notifications')
      .set('Authorization', `Bearer ${citizenToken}`);

    expect(res.status).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
    expect(res.body[0].title).toBe('Welcome');
  });

  it('PUT /api/notifications/:id/read - should mark notification as read', async () => {
    const res = await request(app)
      .put(`/api/notifications/${notificationId}/read`)
      .set('Authorization', `Bearer ${citizenToken}`);

    expect(res.status).toBe(200);
    expect(res.body.isRead).toBe(true);
  });
});
