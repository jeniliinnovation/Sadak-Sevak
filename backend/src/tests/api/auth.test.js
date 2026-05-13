const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');
const User = require('../../models/User');

describe('Auth API Functional Tests', () => {
  beforeAll(async () => {
    await setupTestDB();
  });

  afterAll(async () => {
    await closeTestDB();
  });

  const testUser = {
    name: 'Test User',
    email: 'testapi@example.com',
    password: 'password123'
  };

  it('POST /api/auth/register - should register a new user', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send(testUser);

    expect(res.status).toBe(201);
    expect(res.body).toHaveProperty('id');
    expect(res.body.email).toBe(testUser.email);
  });

  it('POST /api/auth/register - should not allow duplicate email', async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send(testUser);

    expect(res.status).toBe(400);
    expect(res.body).toHaveProperty('error', 'User already exists');
  });

  it('POST /api/auth/login - should login user and return token', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({
        email: testUser.email,
        password: testUser.password
      });

    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('token');
    expect(res.body.email).toBeUndefined(); // Checking implementation details, implementation returns id, name, role, token
    expect(res.body).toHaveProperty('name', testUser.name);
  });

  it('POST /api/auth/login - should fail with wrong password', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({
        email: testUser.email,
        password: 'wrongpassword'
      });

    expect(res.status).toBe(401);
    expect(res.body).toHaveProperty('error', 'Invalid credentials');
  });

  it('POST /api/auth/forgot-password - should generate mock OTP', async () => {
    const res = await request(app)
      .post('/api/auth/forgot-password')
      .send({ email: testUser.email });

    expect(res.status).toBe(200);
    expect(res.body.message).toContain('654321');
  });

  it('POST /api/auth/reset-password - should reset password with OTP', async () => {
    const res = await request(app)
      .post('/api/auth/reset-password')
      .send({
        email: testUser.email,
        otp: '654321',
        newPassword: 'newpassword123'
      });

    expect(res.status).toBe(200);
    expect(res.body.message).toBe('Password reset successful');
  });

  it('GET /api/auth/profile - should require auth', async () => {
    const res = await request(app).get('/api/auth/profile');
    expect(res.status).toBe(401);
  });
});
