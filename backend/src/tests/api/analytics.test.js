const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');

describe('Analytics API Functional Tests', () => {
  let adminToken;

  beforeAll(async () => {
    await setupTestDB();

    // Create Admin
    await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Admin',
        email: 'admin@example.com',
        password: 'password123',
        role: 'admin'
      });
    
    const adminLoginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'admin@example.com',
        password: 'password123'
      });
    adminToken = adminLoginRes.body.token;
  });

  afterAll(async () => {
    await closeTestDB();
  });

  it('GET /api/analytics/metrics - should return metrics', async () => {
    const res = await request(app).get('/api/analytics/metrics');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/analytics/complaints - should return status counts for admin', async () => {
    const res = await request(app)
      .get('/api/analytics/complaints')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/analytics/repairs - should return repair completion analytics', async () => {
    const res = await request(app).get('/api/analytics/repairs');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('total');
    expect(res.body).toHaveProperty('completed');
  });

  it('GET /api/analytics/ai-accuracy - should return AI metrics', async () => {
    const res = await request(app).get('/api/analytics/ai-accuracy');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('overall');
  });
});
