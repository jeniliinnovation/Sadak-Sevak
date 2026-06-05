const User = require('./models/User');
const bcrypt = require('bcryptjs');
const { connectDB, sequelize } = require('./config/db');

const seedUsers = async () => {
    try {
        await connectDB();
        await sequelize.sync();

        const users = [
            {
                name: 'John Citizen',
                email: 'john@gmail.com',
                password: 'user123',
                role: 'citizen',
                isVerified: true
            },
            {
                name: 'Admin Sevak',
                email: 'admin@sadaksevak.com',
                password: 'admin123',
                role: 'admin',
                isVerified: true
            },
            {
                name: 'Team Member 1',
                email: 'fieldteam@sadaksevak.com',
                password: 'team123',
                role: 'team_member',
                isVerified: true
            },
            {
                name: 'Govt. Officer',
                email: 'government@sadaksevak.com',
                password: 'govt123',
                role: 'government',
                isVerified: true
            }
        ];

        for (const userData of users) {
            const salt = await bcrypt.genSalt(10);
            const hashedPassword = await bcrypt.hash(userData.password, salt);
            
            await User.findOrCreate({
                where: { email: userData.email },
                defaults: {
                    ...userData,
                    password: hashedPassword
                }
            });
            console.log(`User ${userData.email} synced.`);
        }

        console.log('Seeding complete.');
        process.exit(0);
    } catch (error) {
        console.error('Seeding failed:', error);
        process.exit(1);
    }
};

seedUsers();
