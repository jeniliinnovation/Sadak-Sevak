const axios = require('axios');

const test = async () => {
  try {
    console.log('Logging in...');
    const loginRes = await axios.post('http://localhost:5000/api/auth/login', {
      email: 'admin@sadaksevak.com',
      password: 'admin123'
    });
    const { token } = loginRes.data;
    console.log('Logged in. Token:', token);

    console.log('Fetching complaints...');
    const complaintsRes = await axios.get('http://localhost:5000/api/complaints');
    const complaint = complaintsRes.data.find(c => c.title.includes('Drainage Overflow'));
    if (!complaint) {
      console.error('Complaint not found!');
      process.exit(1);
    }
    console.log('Found complaint ID:', complaint.id);

    console.log('Fetching bids for this complaint...');
    const bidsRes = await axios.get(`http://localhost:5000/api/bids/complaint/${complaint.id}`, {
      headers: {
        Authorization: `Bearer ${token}`
      }
    });
    console.log('Bids status:', bidsRes.status);
    console.log('Bids data:', JSON.stringify(bidsRes.data, null, 2));
    process.exit(0);
  } catch (err) {
    console.error('Test failed:', err.response?.data || err.message);
    process.exit(1);
  }
};

test();
