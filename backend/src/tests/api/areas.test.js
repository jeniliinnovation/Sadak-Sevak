const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');

describe('Areas API Functional Tests', () => {
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

  it('POST /api/areas - should allow admin to create an area', async () => {
    const res = await request(app)
      .post('/api/areas')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        zoneName: 'Central',
        wardName: 'W1',
        latMin: 10, latMax: 20, lngMin: 70, lngMax: 80
      });

    expect(res.status).toBe(201);
    expect(res.body.zoneName).toBe('Central');
  });

  it('GET /api/areas - should return all areas', async () => {
    const res = await request(app).get('/api/areas');
    expect(res.status).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
  });
});
