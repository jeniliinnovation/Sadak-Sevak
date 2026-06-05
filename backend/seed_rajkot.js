const { sequelize } = require('./src/config/db');
const Complaint = require('./src/models/Complaint');
const User = require('./src/models/User');

const seedRajkotComplaints = async () => {
  try {
    await sequelize.authenticate();
    console.log('Database connected.');

    // Find a citizen user to attribute these to
    const citizen = await User.findOne({ where: { role: 'citizen' } });
    if (!citizen) {
      console.log('No citizen user found. Please register a user first.');
      return;
    }

    const rajkotComplaints = [
      {
        title: 'Huge Pothole near Yagnik Road',
        description: 'Large and deep pothole causing traffic jams and bike accidents during peak hours.',
        status: 'submitted',
        category: 'Pothole',
        priority: 'High',
        citizenId: citizen.id,
        location: {
          lat: 22.3005,
          lng: 70.8015,
          address: 'Yagnik Road, Rajkot, Gujarat',
          area: 'Yagnik Road'
        },
        likesCount: 12,
        confirmationCount: 5,
        media: [{ url: 'https://images.unsplash.com/photo-1544903332-9022630a9117?q=80&w=400&auto=format&fit=crop' }]
      },
      {
        title: 'Street Light Out at Kalavad Road',
        description: 'Complete block is in darkness for 3 nights. Safety concern for pedestrians.',
        status: 'under_review',
        category: 'Street Light',
        priority: 'Medium',
        citizenId: citizen.id,
        location: {
          lat: 22.2902,
          lng: 70.7748,
          address: 'Kalavad Road, Rajkot',
          area: 'Kalavad Road'
        },
        likesCount: 4,
        confirmationCount: 2,
        media: [{ url: 'https://images.unsplash.com/photo-1614959544521-827ac28c049e?q=80&w=400&auto=format&fit=crop' }]
      },
      {
        title: 'Road Crack on Race Course Ring Road',
        description: 'Serious road crack appearing near the garden entrance. Needs immediate inspection.',
        status: 'submitted',
        category: 'Road Crack',
        priority: 'High',
        citizenId: citizen.id,
        location: {
          lat: 22.3088,
          lng: 70.7981,
          address: 'Race Course Ring Rd, Rajkot',
          area: 'Race Course'
        },
        likesCount: 28,
        confirmationCount: 15,
        media: [{ url: 'https://images.unsplash.com/photo-1599424423925-546bcc877399?q=80&w=400&auto=format&fit=crop' }]
      },
      {
        title: 'Overflowing Gutter near University Road',
        description: 'Drainage water is spilling onto the main road near the bus stop.',
        status: 'repair_started',
        category: 'Drainage',
        priority: 'Critical',
        citizenId: citizen.id,
        location: {
          lat: 22.2855,
          lng: 70.7622,
          address: 'University Road, Rajkot',
          area: 'University Area'
        },
        likesCount: 45,
        confirmationCount: 20,
        media: [{ url: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?q=80&w=400&auto=format&fit=crop' }]
      },
      {
        title: 'Trash Piled Up at Kotecha Chowk',
        description: 'Garbage collection has not happened for a week. The smell is unbearable.',
        status: 'submitted',
        category: 'Cleanup',
        priority: 'Low',
        citizenId: citizen.id,
        location: {
          lat: 22.2950,
          lng: 70.7830,
          address: 'Kotecha Chowk, Rajkot',
          area: 'Hanuman Madhi'
        },
        likesCount: 8,
        confirmationCount: 3,
        media: [{ url: 'https://images.unsplash.com/photo-1532187863486-abf9af38bd7c?q=80&w=400&auto=format&fit=crop' }]
      }
    ];

    for (const data of rajkotComplaints) {
      await Complaint.create(data);
    }

    console.log('Successfully seeded 5 Rajkot complaints!');
    process.exit(0);
  } catch (err) {
    console.error('Seeding failed:', err);
    process.exit(1);
  }
};

seedRajkotComplaints();
