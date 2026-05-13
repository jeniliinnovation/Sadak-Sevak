const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');
const Complaint = require('../../models/Complaint');

describe('Interactions API Functional Tests', () => {
  let citizenToken;
  let adminToken;
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

  it('POST /api/complaints/:id/like - should toggle like', async () => {
    const res1 = await request(app)
      .post(`/api/complaints/${complaintId}/like`)
      .set('Authorization', `Bearer ${citizenToken}`);
    expect(res1.body.message).toBe('Liked');

    const res2 = await request(app)
      .post(`/api/complaints/${complaintId}/like`)
      .set('Authorization', `Bearer ${citizenToken}`);
    expect(res2.body.message).toBe('Unliked');
  });

  it('POST /api/complaints/:id/comments - should add a comment', async () => {
    const res = await request(app)
      .post(`/api/complaints/${complaintId}/comments`)
      .set('Authorization', `Bearer ${citizenToken}`)
      .send({ content: 'I see this daily' });

    expect(res.status).toBe(201);
    expect(res.body.content).toBe('I see this daily');
  });

  it('GET /api/complaints/:id/comments - should list comments', async () => {
    const res = await request(app).get(`/api/complaints/${complaintId}/comments`);
    expect(res.status).toBe(200);
    expect(res.body.length).toBeGreaterThan(0);
  });

  it('GET /api/complaints/:id/interactions - should return summary', async () => {
    const res = await request(app).get(`/api/complaints/${complaintId}/interactions`);
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('likesCount');
    expect(res.body).toHaveProperty('commentsCount');
  });
});
