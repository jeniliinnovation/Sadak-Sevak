const { connectDB } = require('./src/config/db');
const Bid = require('./src/models/Bid');
const Complaint = require('./src/models/Complaint');
const User = require('./src/models/User');

const run = async () => {
  try {
    await connectDB();
    const bids = await Bid.findAll({
      include: [
        { model: Complaint, as: 'complaint' },
        { model: User, as: 'contractor', attributes: ['name', 'email'] }
      ]
    });
    console.log(JSON.stringify(bids.map(b => ({
      id: b.id,
      complaintTitle: b.complaint?.title,
      complaintId: b.complaintId,
      cost: b.cost,
      duration: b.duration,
      message: b.message,
      contractor: b.contractor?.name
    })), null, 2));
    process.exit(0);
  } catch (err) {
    console.error(err);
    process.exit(1);
  }
};

run();
