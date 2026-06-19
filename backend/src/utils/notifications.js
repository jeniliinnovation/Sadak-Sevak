const Notification = require('../models/Notification');

/**
 * Creates a notification in the database and pushes it via WebSockets if the user is online.
 * @param {object} io - The socket.io server instance
 * @param {string} userId - The ID of the user to receive the notification
 * @param {string} title - The notification title
 * @param {string} message - The notification message content
 * @param {string} type - The notification type ('status_update', 'comment', 'escalation', 'broadcast')
 */
const sendNotification = async (io, userId, title, message, type = 'status_update') => {
  try {
    if (!userId) return null;

    const notification = await Notification.create({
      userId,
      title,
      message,
      type,
      isRead: false
    });

    if (io) {
      io.to(userId).emit('newNotification', notification);
      console.log(`Live notification emitted to user room ${userId}: "${title}"`);
    }

    return notification;
  } catch (error) {
    console.error('Error creating/sending notification:', error);
    return null;
  }
};

module.exports = { sendNotification };
