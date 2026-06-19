const axios = require('axios');

const test = async () => {
  try {
    // 1. Log in as Rajesh Contractor
    console.log('Logging in...');
    const loginRes = await axios.post('http://localhost:5000/api/auth/login', {
      email: 'rajesh.contractor@builder.in',
      password: 'contract123'
    });
    const { token } = loginRes.data;
    console.log('Logged in successfully. Token:', token);

    // 2. Fetch complaints to get a valid ID
    console.log('Fetching complaints...');
    const complaintsRes = await axios.get('http://localhost:5000/api/complaints');
    const complaint = complaintsRes.data.find(c => c.title.includes('Drainage Overflow'));
    if (!complaint) {
      console.error('No drainage overflow complaint found!');
      process.exit(1);
    }
    console.log('Found complaint ID:', complaint.id);

    // 3. Submit bid
    console.log('Submitting bid...');
    const bidRes = await axios.post(
      'http://localhost:5000/api/bids',
      {
        complaintId: complaint.id,
        cost: 65000.00,
        duration: '6 days',
        message: 'Testing API submission directly'
      },
      {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    );
    console.log('Bid response status:', bidRes.status);
    console.log('Bid response data:', bidRes.data);
    process.exit(0);
  } catch (err) {
    console.error('Test failed:', err.response?.data || err.message);
    process.exit(1);
  }
};

test();

