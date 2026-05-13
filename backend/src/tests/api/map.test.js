const request = require('supertest');
const app = require('../../index');
const { setupTestDB, closeTestDB } = require('../helpers/test_setup');

describe('Map API Functional Tests', () => {
  beforeAll(async () => {
    await setupTestDB();
  });

  afterAll(async () => {
    await closeTestDB();
  });

  it('GET /api/map/live - should return live map data', async () => {
    const res = await request(app).get('/api/map/live');
    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
  });

  it('GET /api/map/summary - should return complaints summary', async () => {
    const res = await request(app).get('/api/map/summary');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('byZone');
    expect(res.body).toHaveProperty('byWard');
  });

  it('GET /api/map/zone/:lat/:lng - should return zone info', async () => {
    const res = await request(app).get('/api/map/zone/19.07/72.87');
    expect(res.status).toBe(200);
    expect(res.body).toHaveProperty('zone');
  });
});
