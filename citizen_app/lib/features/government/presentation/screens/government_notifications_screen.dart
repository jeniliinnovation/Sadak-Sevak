import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:sadak_sevak_citizen/core/network/socket_service.dart';
import 'package:sadak_sevak_citizen/features/home/data/notification_repository.dart';
import 'package:sadak_sevak_citizen/features/home/domain/notification_model.dart';

class GovernmentNotificationsScreen extends StatefulWidget {
  const GovernmentNotificationsScreen({super.key});

  @override
  State<GovernmentNotificationsScreen> createState() =>
      _GovernmentNotificationsScreenState();
}

class _GovernmentNotificationsScreenState
    extends State<GovernmentNotificationsScreen> {
  static const Color _orange = Color(0xFFF4511E);
  static const Color _dark = Color(0xFF1A2332);

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
      if (mounted) setState(() { _notifications = data; _isLoading = false; });
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
          _notifications = _notifications.map((n) => NotificationModel(
            id: n.id, title: n.title, message: n.message,
            type: n.type, isRead: true, createdAt: n.createdAt,
          )).toList();
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Row(children: [
            Icon(Icons.done_all_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('All notifications marked as read'),
          ]),
          backgroundColor: _orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: _dark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('Notifications',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: _dark)),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$_unreadCount',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton.icon(
              onPressed: _isMarkingAll ? null : _markAllAsRead,
              icon: _isMarkingAll
                  ? const SizedBox(
                      width: 12, height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: _orange))
                  : const Icon(Icons.done_all_rounded, size: 16, color: _orange),
              label: const Text('Mark all read',
                  style: TextStyle(color: _orange, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _orange))
          : _notifications.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  color: _orange,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: 50 * index),
                        child: _buildCard(n, index),
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
              color: _orange.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_none_rounded,
                size: 64, color: _orange.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          const Text('No notifications',
              style: TextStyle(
                  color: _dark, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('New complaints and updates will\nappear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildCard(NotificationModel n, int index) {
    final isRead = n.isRead;
    return Dismissible(
      key: Key('${n.id}_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => setState(() => _notifications.removeAt(index)),
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
            color: isRead ? Colors.white : n.color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isRead ? Colors.grey.shade100 : n.color.withOpacity(0.25),
              width: isRead ? 1 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: n.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(n.icon, color: n.color, size: 22),
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
                          child: Text(n.title,
                              style: TextStyle(
                                fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                fontSize: 14,
                                color: _dark,
                              )),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatTime(n.createdAt),
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade400)),
                            if (!isRead) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                    color: _orange, shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    if (n.message.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(n.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              height: 1.4)),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: n.color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_typeLabel(n.type),
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: n.color)),
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

  String _typeLabel(String type) {
    switch (type) {
      case 'status_update': return 'Status Update';
      case 'comment': return 'Comment';
      case 'escalation': return '⚠ Escalation';
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
