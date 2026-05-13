const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');

describe('Escalation API Functional Tests', () => {
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

  it('GET /api/escalation/pending - should list pending escalations', async () => {
    const res = await request(app)
      .get('/api/escalation/pending')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('POST /api/escalation/:id - should allow manual escalation', async () => {
    const res = await request(app)
      .post('/api/escalation/some-uuid')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(res.body.message).toBe('Escalated');
  });
});
