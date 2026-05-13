const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');
const User = require('../../models/User');
const Area = require('../../models/Area');

describe('Complaints API Functional Tests', () => {
  let citizenToken;
  let adminToken;
  let citizenId;
  let complaintId;

  beforeAll(async () => {
    await setupTestDB();

    // Create a citizen
    const citizenRes = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Citizen User',
        email: 'citizen@example.com',
        password: 'password123',
        role: 'citizen'
      });
    citizenId = citizenRes.body.id;

    const loginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'citizen@example.com',
        password: 'password123'
      });
    citizenToken = loginRes.body.token;

    // Create an admin
    await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Admin User',
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

    // Create an area for SARA enrichment
    await Area.create({
      zoneName: 'Central',
      wardName: 'W1',
      latMin: 18.0, latMax: 20.0, lngMin: 70.0, lngMax: 74.0
    });
  });

  afterAll(async () => {
    await closeTestDB();
  });

  it('POST /api/complaints - should create a complaint with SARA enrichment', async () => {
    const res = await request(app)
      .post('/api/complaints')
      .set('Authorization', `Bearer ${citizenToken}`)
      .send({
        title: 'Main Road Pothole',
        description: 'Dangerous pothole',
        location: { lat: 19.0, lng: 72.8 }
      });

    expect(res.status).toBe(201);
    expect(res.body.title).toBe('Main Road Pothole');
    expect(res.body.location.zone).toBe('Central');
    complaintId = res.body.id;
  });

  it('GET /api/complaints - should return all complaints', async () => {
    const res = await request(app).get('/api/complaints');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThan(0);
  });

  it('GET /api/complaints/:id - should return specific complaint details', async () => {
    const res = await request(app).get(`/api/complaints/${complaintId}`);
    expect(res.status).toBe(200);
    expect(res.body.id).toBe(complaintId);
  });

  it('PUT /api/complaints/:id/status - should allow admin to update status', async () => {
    const res = await request(app)
      .put(`/api/complaints/${complaintId}/status`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'under_review' });

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('under_review');
  });

  it('POST /api/complaints/:id/verify - should allow owner to verify and close', async () => {
    const res = await request(app)
      .post(`/api/complaints/${complaintId}/verify`)
      .set('Authorization', `Bearer ${citizenToken}`);

    expect(res.status).toBe(200);
    expect(res.body.complaint.status).toBe('verified_closed');
  });

  it('DELETE /api/complaints/:id - should allow admin to delete', async () => {
    const res = await request(app)
      .delete(`/api/complaints/${complaintId}`)
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(res.body.message).toBe('Deleted');
  });
});
