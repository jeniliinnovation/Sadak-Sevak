const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');
const Complaint = require('../../models/Complaint');
const Contractor = require('../../models/Contractor');
const { GovernmentAdmin, RolesLegend } = require('../../models/AdminModels');

describe('Admin API Functional Tests', () => {
  let adminToken;
  let citizenToken;
  let complaintId;

  let teamMemberId;

  beforeAll(async () => {
    await setupTestDB();

    // Create Admin
    await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Admin User',
        email: 'admin@admin.com',
        password: 'password123',
        role: 'admin'
      });
    
    const adminLoginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'admin@admin.com',
        password: 'password123'
      });
    adminToken = adminLoginRes.body.token;

    // Create Team Member
    const teamRes = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Field Team 1',
        email: 'team1@city.gov',
        password: 'password123',
        role: 'team_member'
      });
    teamMemberId = teamRes.body.id;

    // Create Citizen
    const citizenRes = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Citizen',
        email: 'citizen@citizen.com',
        password: 'password123',
        role: 'citizen'
      });
    
    const citizenLoginRes = await request(app)
      .post('/api/auth/login')
      .send({
        email: 'citizen@citizen.com',
        password: 'password123'
      });
    citizenToken = citizenLoginRes.body.token;

    // Create a complaint to assign
    const compRes = await request(app)
      .post('/api/complaints')
      .set('Authorization', `Bearer ${citizenToken}`)
      .send({
        title: 'Road Issue',
        description: 'Detail',
        location: { lat: 10, lng: 20 }
      });
    complaintId = compRes.body.id;

    // Seed some admin data
    await GovernmentAdmin.create({ deptName: 'PWD', headName: 'Jane Doe', contactEmail: 'pwd@city.gov' });
    await RolesLegend.create({ roleSymbol: 'A', meaning: 'Admin' });
  });

  afterAll(async () => {
    await closeTestDB();
  });

  it('GET /api/admin/complaints - should list all complaints for admin', async () => {
    const res = await request(app)
      .get('/api/admin/complaints')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body.length).toBeGreaterThan(0);
  });

  it('PUT /api/admin/complaints/:id/assign - should allow admin to assign a team', async () => {
    const res = await request(app)
      .put(`/api/admin/complaints/${complaintId}/assign`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ teamId: teamMemberId });

    expect(res.status).toBe(200);
    expect(res.body.assignedTeamId).toBe(teamMemberId);
    expect(res.body.status).toBe('team_assigned');
  });

  it('POST /api/admin/contractors - should allow admin to add contractor', async () => {
    const res = await request(app)
      .post('/api/admin/contractors')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ companyName: 'Repair Co', specialization: 'Potholes' });

    expect(res.status).toBe(201);
    expect(res.body.companyName).toBe('Repair Co');
  });

  it('GET /api/admin/government - should return government data', async () => {
    const res = await request(app)
      .get('/api/admin/government')
      .set('Authorization', `Bearer ${adminToken}`);

    expect(res.status).toBe(200);
    expect(res.body[0].deptName).toBe('PWD');
  });

  it('GET /api/admin/roles - should return roles legend', async () => {
    const res = await request(app).get('/api/admin/roles');
    expect(res.status).toBe(200);
    expect(res.body[0].roleSymbol).toBe('A');
  });
});
