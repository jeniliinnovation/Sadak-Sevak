const { sequelize, connectDB } = require('./src/config/db');
const User = require('./src/models/User');
const Complaint = require('./src/models/Complaint');
const Contractor = require('./src/models/Contractor');
const Notification = require('./src/models/Notification');
const bcrypt = require('bcryptjs');

const Comment = require('./src/models/Comment');
require('./src/models/Department');
require('./src/models/EscalationLog');
require('./src/models/AIResult');
require('./src/models/Interactions');
require('./src/models/MissingModules');
require('./src/models/Area');
require('./src/models/AdminModels');

const seedData = async () => {
  try {
    await connectDB();

    // Disable foreign key checks for sync
    await sequelize.query('SET FOREIGN_KEY_CHECKS = 0');
    await sequelize.sync({ force: true });
    await sequelize.query('SET FOREIGN_KEY_CHECKS = 1');

    console.log('Database synced (force: true). Seeding data...');

    const hash = (pwd) => bcrypt.hash(pwd, 10);

    // ─────────────────────────────────────────
    // 1. GOVERNMENT STAFF USERS
    // ─────────────────────────────────────────
    const adminPassword = await hash('admin123');
    const admin = await User.create({
      name: 'Master Admin',
      email: 'admin@sadaksevak.com',
      password: adminPassword,
      role: 'admin',
      isVerified: true,
      avatar: 'https://api.dicebear.com/7.x/initials/svg?seed=MA',
    });
    console.log('Created admin:', admin.email);

    const govPassword = await hash('gov123');

    const govUsers = await User.bulkCreate([
      {
        name: 'Ravi Kumar',
        email: 'ravi.kumar@gov.in',
        password: govPassword,
        role: 'department_head',
        isVerified: true,
        avatar: 'https://api.dicebear.com/7.x/initials/svg?seed=RK',
      },
      {
        name: 'Priya Mehta',
        email: 'priya.mehta@gov.in',
        password: govPassword,
        role: 'team_member',
        isVerified: true,
        avatar: 'https://api.dicebear.com/7.x/initials/svg?seed=PM',
      },
      {
        name: 'Arjun Singh',
        email: 'arjun.singh@gov.in',
        password: govPassword,
        role: 'team_member',
        isVerified: true,
        avatar: 'https://api.dicebear.com/7.x/initials/svg?seed=AS',
      },
      {
        name: 'Sneha Patel',
        email: 'sneha.patel@gov.in',
        password: govPassword,
        role: 'government',
        isVerified: true,
        avatar: 'https://api.dicebear.com/7.x/initials/svg?seed=SP',
      },
      {
        name: 'Mohan Das',
        email: 'mohan.das@gov.in',
        password: govPassword,
        role: 'team_member',
        isVerified: false,
        avatar: 'https://api.dicebear.com/7.x/initials/svg?seed=MD',
      },
      {
        name: 'Kavita Sharma',
        email: 'kavita.sharma@gov.in',
        password: govPassword,
        role: 'department_head',
        isVerified: true,
        avatar: 'https://api.dicebear.com/7.x/initials/svg?seed=KS',
      },
    ]);
    console.log(`Created ${govUsers.length} government staff users.`);

    // ─────────────────────────────────────────
    // 2. CITIZENS
    // ─────────────────────────────────────────
    const userPassword = await hash('user123');
    const citizen1 = await User.create({
      name: 'John Doe',
      email: 'john@gmail.com',
      password: userPassword,
      role: 'citizen',
      isVerified: true,
      avatar: 'https://api.dicebear.com/7.x/initials/svg?seed=JD',
    });
    const citizen2 = await User.create({
      name: 'Jane Smith',
      email: 'jane@example.com',
      password: userPassword,
      role: 'citizen',
      isVerified: true,
      avatar: 'https://api.dicebear.com/7.x/initials/svg?seed=JS',
    });
    const citizen3 = await User.create({
      name: 'Ahmed Khan',
      email: 'ahmed.khan@gmail.com',
      password: userPassword,
      role: 'citizen',
      isVerified: false,
      avatar: 'https://api.dicebear.com/7.x/initials/svg?seed=AK',
    });
    console.log('Created 3 citizen users.');

    // ─────────────────────────────────────────
    // 3. COMPLAINTS
    // ─────────────────────────────────────────
    await Complaint.bulkCreate([
      {
        title: 'Large Pothole on MG Road',
        description: 'Deep pothole causing traffic accidents near the junction. Needs urgent repair.',
        category: 'Potholes',
        priority: 'High',
        media: { url: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957', type: 'image' },
        location: { lat: 22.3039, lng: 70.8022, address: 'MG Road, Zone 2', area: 'Zone 2' },
        citizenId: citizen1.id,
        status: 'repair_started',
      },
      {
        title: 'Broken Street Light - Park Avenue',
        description: 'Street light has been non-functional for 5 days. Safety concern at night.',
        category: 'Street Light',
        priority: 'Medium',
        media: { url: 'https://images.unsplash.com/photo-1518173946687-a4c3a3b7293e', type: 'image' },
        location: { lat: 22.3120, lng: 70.8050, address: 'Park Ave, Zone 1', area: 'Zone 1' },
        citizenId: citizen1.id,
        status: 'team_assigned',
      },
      {
        title: 'Drainage Overflow - Block A',
        description: 'Drainage is overflowing onto the road causing waterlogging.',
        category: 'Drainage',
        priority: 'High',
        media: { url: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a', type: 'image' },
        location: { lat: 22.2980, lng: 70.7950, address: 'Block A, Zone 1', area: 'Zone 1' },
        citizenId: citizen2.id,
        status: 'submitted',
      },
      {
        title: 'Road Damage - Canal Road',
        description: 'Road surface has severely deteriorated after monsoon season.',
        category: 'Road Damage',
        priority: 'High',
        media: { url: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957', type: 'image' },
        location: { lat: 22.3200, lng: 70.8100, address: 'Canal Road, Zone 3', area: 'Zone 3' },
        citizenId: citizen2.id,
        status: 'verified_closed',
      },
      {
        title: 'Garbage Pile - Model Town',
        description: 'Large pile of garbage not being collected for 2 weeks.',
        category: 'Sanitation',
        priority: 'Medium',
        media: { url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64', type: 'image' },
        location: { lat: 22.3080, lng: 70.7990, address: 'Model Town, Zone 2', area: 'Zone 2' },
        citizenId: citizen3.id,
        status: 'submitted',
      },
      {
        title: 'Pothole Cluster - University Road',
        description: 'Multiple potholes along a 200m stretch of the road.',
        category: 'Potholes',
        priority: 'Medium',
        media: { url: 'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957', type: 'image' },
        location: { lat: 22.3150, lng: 70.8070, address: 'University Road, Zone 1', area: 'Zone 1' },
        citizenId: citizen3.id,
        status: 'repair_completed',
      },
    ]);
    console.log('Created 6 complaints.');

    // ─────────────────────────────────────────
    // 4. CONTRACTORS
    // ─────────────────────────────────────────
    await Contractor.bulkCreate([
      {
        companyName: 'City Road Services Pvt Ltd',
        specialization: 'Road Repair & Resurfacing',
        rating: 4.8,
      },
      {
        companyName: 'Gujarat Infrastructure Works',
        specialization: 'Drainage & Sewage Systems',
        rating: 4.5,
      },
      {
        companyName: 'Bright Lights Solutions',
        specialization: 'Street Lighting & Electrical',
        rating: 4.7,
      },
      {
        companyName: 'PatchPro Civil Contractors',
        specialization: 'Pothole Filling & Patching',
        rating: 4.2,
      },
      {
        companyName: 'Urban Infrastructure Ltd',
        specialization: 'General Civil Works',
        rating: 4.6,
      },
      {
        companyName: 'RoadMaster Engineering Co.',
        specialization: 'Road Damage & Resurfacing',
        rating: 4.9,
      },
    ]);
    console.log('Created 6 contractors.');

    // ─────────────────────────────────────────
    // 5. NOTIFICATIONS (linked to admin user)
    // ─────────────────────────────────────────
    await Notification.bulkCreate([
      {
        title: 'New High Priority Complaint',
        message: 'A new HIGH priority complaint has been submitted for MG Road pothole. Immediate action required.',
        type: 'status_update',
        isRead: false,
        userId: admin.id,
      },
      {
        title: 'Work Order Completed',
        message: 'Team Alpha has completed the Canal Road repair project. Please verify and close the ticket.',
        type: 'status_update',
        isRead: false,
        userId: admin.id,
      },
      {
        title: 'Approval Pending Review',
        message: 'Work request APP-003 for Street Light Replacement is pending your approval since 2 days.',
        type: 'escalation',
        isRead: false,
        userId: admin.id,
      },
      {
        title: 'New Contractor Registered',
        message: 'RoadMaster Engineering Co. has been added to the contractor directory with a 4.9 star rating.',
        type: 'broadcast',
        isRead: true,
        userId: admin.id,
      },
      {
        title: 'Team Bravo - Assignment Update',
        message: 'Team Bravo has been successfully assigned to Block A Drainage repair (WRK-002).',
        type: 'status_update',
        isRead: true,
        userId: admin.id,
      },
      {
        title: 'Monthly Report Ready',
        message: 'The May 2024 analytics report has been generated. View it in the Analytics section.',
        type: 'broadcast',
        isRead: true,
        userId: admin.id,
      },
      {
        title: 'Complaint Escalated',
        message: 'Complaint CMP-2024-003 has been escalated due to no action taken within 72 hours.',
        type: 'escalation',
        isRead: false,
        userId: admin.id,
      },
      {
        title: 'New Field Operation Logged',
        message: 'Team Alpha logged a new road inspection at University Road at 10:30 AM today.',
        type: 'status_update',
        isRead: true,
        userId: admin.id,
      },
    ]);
    console.log('Created 8 notifications for admin.');

    // Seed sample chat discussion comments
    const ravi = await User.findOne({ where: { email: 'ravi.kumar@gov.in' } });
    const priya = await User.findOne({ where: { email: 'priya.mehta@gov.in' } });
    const firstComplaint = await Complaint.findOne({ where: { title: 'Large Pothole on MG Road' } });

    if (firstComplaint && citizen1 && ravi && priya) {
      await Comment.bulkCreate([
        {
          content: "I reported this pothole. It's very deep and causing traffic issues.",
          complaintId: firstComplaint.id,
          userId: citizen1.id,
        },
        {
          content: "Thanks for reporting. I have assigned the Road Repair Unit to investigate this immediately.",
          complaintId: firstComplaint.id,
          userId: ravi.id,
        },
        {
          content: "We have received the work order and are preparing the materials. We will start repairs tomorrow morning.",
          complaintId: firstComplaint.id,
          userId: priya.id,
        }
      ]);
      console.log('Seeded sample discussion comments between Citizen, Gov Officer, and Field Team.');
    }

    console.log('\n✅ Database seeded successfully!');
    console.log('   Admin: admin@sadaksevak.com / admin123');
    console.log('   Govt Staff: ravi.kumar@gov.in / gov123');
    console.log('   Citizens: john@gmail.com / user123');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding data:', error);
    process.exit(1);
  }
};

seedData();
