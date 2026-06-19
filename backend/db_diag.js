const { sequelize, connectDB } = require('./src/config/db');
const Bid = require('./src/models/Bid');
const User = require('./src/models/User');

const run = async () => {
  try {
    await connectDB();
    console.log('Querying bids...');
    const bids = await Bid.findAll({
      include: [
        { model: User, as: 'contractor', attributes: ['id', 'name', 'email'] }
      ]
    });
    console.log('Bids queried successfully:', bids.length);
  } catch (err) {
    console.error('Error querying bids table:', err);
  } finally {
    await sequelize.close();
  }
};

run();
