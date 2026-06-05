import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/government/domain/models/notification_model.dart';

class GovernmentNotificationsScreen extends StatefulWidget {
  const GovernmentNotificationsScreen({super.key});

  @override
  State<GovernmentNotificationsScreen> createState() => _GovernmentNotificationsScreenState();
}

class _GovernmentNotificationsScreenState extends State<GovernmentNotificationsScreen> {
  final GovernmentRepository _repository = GovernmentRepository();
  bool _isLoading = true;
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final notifications = await _repository.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _markAllAsRead() async {
    // Optimistic UI update
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    // In a real app we'd call an API to mark all read
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All notifications marked as read.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text(
              'Mark all as read',
              style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          )
        ],
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryOrange))
        : _notifications.isEmpty 
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final isRead = notification.isRead;
                
                // Simulate grouping by day based on index for demo purposes
                final isToday = index < 2; 
                final showHeader = index == 0 || index == 2;
                final headerText = isToday ? 'Today' : 'Earlier';

                Widget card = Dismissible(
                  key: Key(notification.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      _notifications.removeAt(index);
                    });
                  },
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : const Color(0xFFFFF3E0).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                      border: Border.all(color: isRead ? Colors.grey.shade100 : const Color(0xFFFFCC80).withOpacity(0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: notification.color,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: notification.color.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(notification.icon, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 16),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF263238),
                                ),
                              ),
                              if (notification.message.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  notification.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Text(
                                notification.time,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        if (!isRead)
                          Container(
                            height: 8,
                            width: 8,
                            margin: const EdgeInsets.only(top: 4, left: 8),
                            decoration: const BoxDecoration(
                              color: primaryOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );

                if (showHeader) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 8, bottom: 12),
                        child: Text(
                          headerText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        delay: Duration(milliseconds: 50 * index),
                        child: card,
                      ),
                    ],
                  );
                }

                return FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  delay: Duration(milliseconds: 50 * index),
                  child: card,
                );
              },
            ),
    );
  }
}
