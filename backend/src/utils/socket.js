const Comment = require('../models/Comment');
const User = require('../models/User');
const Complaint = require('../models/Complaint');
const { sendNotification } = require('./notifications');

module.exports = (io) => {
  io.on('connection', (socket) => {
    console.log(`Socket connected: ${socket.id}`);

    // Join a user-specific notification room
    socket.on('joinUserRoom', ({ userId }) => {
      socket.join(userId);
      console.log(`Socket ${socket.id} joined user room: ${userId}`);
    });

    // Join a complaint room
    socket.on('joinRoom', ({ complaintId }) => {
      socket.join(complaintId);
      console.log(`Socket ${socket.id} joined room: ${complaintId}`);
    });

    // Handle sending message
    socket.on('sendMessage', async ({ complaintId, userId, content }) => {
      try {
        console.log(`Message received from user ${userId} for complaint ${complaintId}: ${content}`);
        
        // Create comment in DB
        const comment = await Comment.create({
          content,
          complaintId,
          userId
        });

        // Fetch user info to include in broadcast
        const fullComment = await Comment.findByPk(comment.id, {
          include: [{ model: User, attributes: ['name', 'avatar', 'role'] }]
        });

        // Broadcast comment to the room
        io.to(complaintId).emit('newMessage', fullComment);

        // Fetch complaint details to get citizen and team IDs for alerts
        const complaint = await Complaint.findByPk(complaintId);
        if (complaint) {
          // Notify the citizen if they aren't the sender
          if (complaint.citizenId && complaint.citizenId !== userId) {
            await sendNotification(
              io,
              complaint.citizenId,
              'New Message',
              `New message in "${complaint.title}": ${content}`,
              'comment'
            );
          }
          // Notify the assigned team member if they aren't the sender
          if (complaint.assignedTeamId && complaint.assignedTeamId !== userId) {
            await sendNotification(
              io,
              complaint.assignedTeamId,
              'New Message',
              `New message in "${complaint.title}": ${content}`,
              'comment'
            );
          }
        }
      } catch (error) {
        console.error('Socket message error:', error);
        socket.emit('socketError', { message: 'Failed to send message' });
      }
    });

    // Leave a room
    socket.on('leaveRoom', ({ complaintId }) => {
      socket.leave(complaintId);
      console.log(`Socket ${socket.id} left room: ${complaintId}`);
    });

    socket.on('disconnect', () => {
      console.log(`Socket disconnected: ${socket.id}`);
    });
  });
};
