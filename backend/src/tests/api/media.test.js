const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');

// Mock upload middleware
jest.mock('../../middleware/upload', () => {
  return {
    single: () => (req, res, next) => {
      req.file = {
        path: 'http://cloudinary.com/test.jpg',
        filename: 'test_file_id'
      };
      next();
    }
  };
});

describe('Media API Functional Tests', () => {
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

  it('POST /api/media/upload - should return mock upload info', async () => {
    const res = await request(app)
      .post('/api/media/upload')
      .set('Authorization', `Bearer ${citizenToken}`)
      .attach('file', Buffer.from('test'), 'test.jpg'); // The mock will overwrite the result

    expect(res.status).toBe(200);
    expect(res.body.url).toBe('http://cloudinary.com/test.jpg');
  });

  it('DELETE /api/media/:id - should schedule deletion', async () => {
    const res = await request(app)
      .delete('/api/media/some-id')
      .set('Authorization', `Bearer ${citizenToken}`);

    expect(res.status).toBe(200);
    expect(res.body.message).toBe('Media deletion scheduled');
  });
});
