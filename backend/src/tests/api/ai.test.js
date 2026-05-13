const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');
const Complaint = require('../../models/Complaint');

describe('AI API Functional Tests', () => {
  let citizenToken;
  let complaintId;

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

    // Create Complaint
    const compRes = await request(app)
      .post('/api/complaints')
      .set('Authorization', `Bearer ${citizenToken}`)
      .send({
        title: 'Pothole',
        description: 'Large',
        location: { lat: 1, lng: 1 }
      });
    complaintId = compRes.body.id;
  });

  afterAll(async () => {
    await closeTestDB();
  });

  it('POST /api/ai/analyze - should simulate AI analysis', async () => {
    const res = await request(app)
      .post('/api/ai/analyze')
      .set('Authorization', `Bearer ${citizenToken}`)
      .send({ complaintId });

    expect(res.status).toBe(200);
    expect(res.body.message).toBe('Analysis complete');
    expect(res.body.results).toHaveProperty('roadHealthScore', 75);
  });

  it('GET /api/ai/score/:id - should return road health score', async () => {
    const res = await request(app).get(`/api/ai/score/${complaintId}`);
    expect(res.status).toBe(200);
    expect(res.body.score).toBe(75);
  });
});
