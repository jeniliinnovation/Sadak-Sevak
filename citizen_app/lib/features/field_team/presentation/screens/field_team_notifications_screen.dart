import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../../../core/network/socket_service.dart';
import '../../../home/data/notification_repository.dart';
import '../../../home/domain/notification_model.dart';

class FieldTeamNotificationsScreen extends StatefulWidget {
  const FieldTeamNotificationsScreen({super.key});

  @override
  State<FieldTeamNotificationsScreen> createState() =>
      _FieldTeamNotificationsScreenState();
}

class _FieldTeamNotificationsScreenState
    extends State<FieldTeamNotificationsScreen> {
  static const Color _blue = Color(0xFF4A80F0);
  static const Color _dark = Color(0xFF0D47A1);

  final _repo = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  bool _isMarkingAll = false;
  StreamSubscription<dynamic>? _notificationSub;

  @override
  void initState() {
    super.initState();
    _load().then((_) => _markAllAsRead());
    _notificationSub = SocketService().notificationStream.listen((_) {
      if (mounted) {
        _load(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final data = await _repo.getNotifications();
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
      await _repo.markAsRead(n.id);
      if (mounted) {
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
      await _repo.markAllAsRead();
      if (mounted) {
        setState(() {
          _notifications = _notifications
              .map((n) => NotificationModel(
                    id: n.id,
                    title: n.title,
                    message: n.message,
                    type: n.type,
                    isRead: true,
                    createdAt: n.createdAt,
                  ))
              .toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.done_all_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('All notifications marked as read'),
          ]),
          backgroundColor: _blue,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (_) {} finally {
      if (mounted) setState(() => _isMarkingAll = false);
    }
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('Notifications',
                style: TextStyle(
                    color: _dark,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount new',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton.icon(
                onPressed: _isMarkingAll ? null : _markAllAsRead,
                icon: _isMarkingAll
                    ? const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: _blue))
                    : const Icon(Icons.done_all_rounded,
                        size: 16, color: _blue),
                label: const Text('Mark all',
                    style: TextStyle(
                        color: _blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : _notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: _blue,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _notifications.length,
                    itemBuilder: (context, i) {
                      final n = _notifications[i];
                      return FadeInUp(
                        delay: Duration(milliseconds: 50 * i),
                        child: _notifCard(n, i),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _blue.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded,
                size: 64, color: _blue.withOpacity(0.4)),
          ),
          const SizedBox(height: 16),
          const Text('No notifications yet',
              style: TextStyle(
                  color: _dark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Task updates, assignments and alerts\nwill appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _notifCard(NotificationModel n, int i) {
    final unread = !n.isRead;

    return Dismissible(
      key: Key('notif_${n.id}_$i'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          setState(() => _notifications.removeWhere((x) => x.id == n.id)),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => _markAsRead(n),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: unread ? n.color.withOpacity(0.04) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: unread
                  ? n.color.withOpacity(0.2)
                  : Colors.grey.shade100,
              width: unread ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: n.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(n.icon, color: n.color, size: 22),
              ),
              const SizedBox(width: 14),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontWeight: unread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: 14,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatTime(n.createdAt),
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade400),
                            ),
                            if (unread) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: n.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    // Message
                    Text(
                      n.message,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    // Type badge
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: n.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_typeIcon(n.type),
                                  size: 11, color: n.color),
                              const SizedBox(width: 4),
                              Text(
                                _typeLabel(n.type),
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: n.color),
                              ),
                            ],
                          ),
                        ),
                        if (unread) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Tap to mark read',
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade400),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'status_update':
        return Icons.update_rounded;
      case 'comment':
        return Icons.chat_bubble_outline_rounded;
      case 'escalation':
        return Icons.warning_amber_rounded;
      case 'broadcast':
        return Icons.campaign_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'status_update':
        return 'Task Update';
      case 'comment':
        return 'New Comment';
      case 'escalation':
        return 'Escalation';
      case 'broadcast':
        return 'Announcement';
      default:
        return 'Notification';
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
