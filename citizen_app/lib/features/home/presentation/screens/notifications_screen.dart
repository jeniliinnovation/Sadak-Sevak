import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../../core/network/socket_service.dart';
import '../../data/notification_repository.dart';
import '../../domain/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notifyRepo = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _isMarkingAll = false;
  StreamSubscription<dynamic>? _notificationSub;

  @override
  void initState() {
    super.initState();
    // Load notifications then mark all as read when the screen opens
    _loadNotifications().then((_) async {
      // Mark all as read on open so the badge clears and items are updated server-side
      try {
        await _markAllAsRead();
      } catch (_) {}
    });
    _notificationSub = SocketService().notificationStream.listen((_) {
      if (mounted) {
        _loadNotifications(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final data = await _notifyRepo.getNotifications();
      if (mounted) {
        setState(() {
          _notifications = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(NotificationModel n) async {
    if (n.isRead) return;
    try {
      await _notifyRepo.markAsRead(n.id);
      if (mounted) {
        // Remove the notification locally so it disappears after clicking
        setState(() {
          _notifications.removeWhere((x) => x.id == n.id);
        });
      }
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    if (_isMarkingAll) return;
    setState(() => _isMarkingAll = true);
    try {
      await _notifyRepo.markAllAsRead();
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((n) => NotificationModel(
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: true,
            createdAt: n.createdAt,
          )).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.done_all_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('All notifications marked as read'),
              ],
            ),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isMarkingAll = false);
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text('Notifications',
                style: TextStyle(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!_isLoading && _unreadCount > 0)
            TextButton.icon(
              onPressed: _isMarkingAll ? null : _markAllAsRead,
              icon: _isMarkingAll
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primaryColor))
                  : const Icon(Icons.done_all_rounded,
                      size: 16, color: AppTheme.primaryColor),
              label: const Text('Mark all read',
                  style:
                      TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
            ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppTheme.secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: AppTheme.primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notify = _notifications[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: 40 * index),
                        child: _buildNotificationItem(notify),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded,
                size: 64, color: AppTheme.primaryColor.withOpacity(0.4)),
          ),
          const SizedBox(height: 16),
          const Text('No notifications yet',
              style: TextStyle(
                  color: AppTheme.secondaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'You will be notified when your\nreports get updates.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notify) {
    return GestureDetector(
      onTap: () => _markAsRead(notify),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notify.isRead ? Colors.white : notify.color.withOpacity(0.04),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notify.isRead
                ? Colors.grey.shade100
                : notify.color.withOpacity(0.2),
            width: notify.isRead ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notify.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(notify.icon, color: notify.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notify.title,
                          style: TextStyle(
                            fontWeight: notify.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(notify.createdAt),
                            style: TextStyle(
                                color: Colors.grey.shade400, fontSize: 11),
                          ),
                          if (!notify.isRead) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: notify.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notify.message,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  // Type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: notify.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _typeLabel(notify.type),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: notify.color),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'status_update': return 'Status Update';
      case 'comment': return 'New Comment';
      case 'escalation': return 'Escalation';
      case 'broadcast': return 'Announcement';
      default: return 'Notification';
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('dd MMM').format(dt);
  }
}
