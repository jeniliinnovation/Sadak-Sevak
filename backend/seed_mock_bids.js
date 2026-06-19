const { sequelize, connectDB } = require('./src/config/db');
const User = require('./src/models/User');
const Complaint = require('./src/models/Complaint');
const Bid = require('./src/models/Bid');

const run = async () => {
  try {
    await connectDB();
    
    // Find Rajesh Contractor
    const contractor = await User.findOne({ where: { email: 'rajesh.contractor@builder.in' } });
    if (!contractor) {
      console.log('Rajesh Contractor not found! Please make sure seed.js has been run.');
      process.exit(1);
    }

    // Find complaints
    const complaints = await Complaint.findAll({ order: [['createdAt', 'ASC']] });
    if (complaints.length === 0) {
      console.log('No complaints found! Please make sure seed.js has been run.');
      process.exit(1);
    }

    // Clear existing bids first
    await Bid.destroy({ where: {} });

    // Seed bid 1 (MG Road)
    await Bid.create({
      complaintId: complaints[0].id,
      contractorId: contractor.id,
      cost: 45000.00,
      duration: '5 Days',
      message: 'Will repair the pothole using industrial grade asphalt with double compaction.'
    });

    // Seed bid 2 (Park Avenue)
    if (complaints.length > 1) {
      await Bid.create({
        complaintId: complaints[1].id,
        contractorId: contractor.id,
        cost: 125000.00,
        duration: '10 Days',
        message: 'Complete replacement of street lighting and post reinforcement.'
      });
    }

    // Find the Drainage Overflow complaint specifically by title to be precise
    const drainageComplaint = complaints.find(c => c.title.includes('Drainage Overflow'));
    if (drainageComplaint) {
      await Bid.create({
        complaintId: drainageComplaint.id,
        contractorId: contractor.id,
        cost: 50000.00,
        duration: '7 days',
        message: 'i will do that work in 5 dayes'
      });
      console.log('Seeded Drainage Overflow bid.');
    }

    console.log('Seeded mock bids successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Seeding bids failed:', error);
    process.exit(1);
  }
};

run();
