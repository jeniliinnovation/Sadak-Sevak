const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const swaggerUi = require('swagger-ui-express');
const swaggerJsdoc = require('swagger-jsdoc');
const http = require('http');
const { Server } = require('socket.io');
require('dotenv').config();

const { connectDB, sequelize } = require('./config/db');

// Swagger Configuration
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Sadak-Sevak API',
      version: '1.0.0',
      description: 'Interactive API documentation for the Sadak-Sevak Platform',
    },
    servers: [
      {
        url: 'http://localhost:5000',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },
  },
  apis: ['./src/routes/*.js'], // Path to the API docs
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);

// Import All 12 Models for synchronization
require('./models/User');
require('./models/Complaint');
require('./models/Comment');
require('./models/Notification');
require('./models/Department');
require('./models/Contractor');
require('./models/EscalationLog');
require('./models/AIResult');
const { Like, Confirmation } = require('./models/Interactions');
require('./models/MissingModules');
require('./models/Area');
require('./models/AdminModels');
require('./models/Bid');



const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  }
});

app.set('io', io);

const socketHandler = require('./utils/socket');
socketHandler(io);

// Middleware
app.use(helmet({
  crossOriginResourcePolicy: false,
  contentSecurityPolicy: false,
}));
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
}));
app.use(express.json());
app.use(morgan('dev'));
app.use('/uploads', express.static('uploads'));

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/complaints', require('./routes/complaints'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/ai', require('./routes/ai'));
app.use('/api/map', require('./routes/map'));
app.use('/api/media', require('./routes/media'));
app.use('/api/notifications', require('./routes/notifications'));
app.use('/api/escalation', require('./routes/escalation'));
app.use('/api/analytics', require('./routes/analytics'));
app.use('/api', require('./routes/interactions'));
app.use('/api/roles', require('./routes/roles'));
app.use('/api/summary', require('./routes/summary'));
app.use('/api/areas', require('./routes/areas'));
app.use('/api/bids', require('./routes/bids'));



// Swagger UI
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

app.get('/', (req, res) => {
  res.json({ message: 'Sadak Sevak API is running' });
});

// Sync Database and Start Server
const PORT = process.env.PORT || 5000;

const startServer = async () => {
  try {
    await connectDB();
    
    // Disable foreign key checks for sync
    await sequelize.query('SET FOREIGN_KEY_CHECKS = 0');
    const syncOptions = process.env.FORCE_SYNC === 'true' ? { force: true } : {};
    await sequelize.sync(syncOptions);
    await sequelize.query('SET FOREIGN_KEY_CHECKS = 1');
    console.log('Database synced', syncOptions);

    server.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
      console.log(`Swagger UI available at: http://localhost:${PORT}/api-docs`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
  }
};

if (process.env.NODE_ENV !== 'test') {
  startServer();
}

module.exports = app;
