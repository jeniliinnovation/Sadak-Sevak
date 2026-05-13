const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');

describe('Misc API Functional Tests (Roles, Summary)', () => {
  let citizenToken;

  beforeAll(async () => {
    await setupTestDB();

    // Create Citizen
    await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Citizen',
        email: 'citizen@example.com',
        password: 'password123',
        role: 'citizen'
      });
    
    const citizenLoginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'citizen@example.com',
        password: 'password123'
      });
    citizenToken = citizenLoginRes.body.token;
  });

  afterAll(async () => {
    await closeTestDB();
  });

  it('GET /api/roles - should return roles legend', async () => {
    const res = await request(app).get('/api/roles');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/summary - should return summary table for authenticated user', async () => {
    const res = await request(app)
      .get('/api/summary')
      .set('Authorization', `Bearer ${citizenToken}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });
});
