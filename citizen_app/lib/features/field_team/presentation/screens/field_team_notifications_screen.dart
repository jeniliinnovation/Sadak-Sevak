import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class FieldTeamNotificationsScreen extends StatefulWidget {
  const FieldTeamNotificationsScreen({super.key});

  @override
  State<FieldTeamNotificationsScreen> createState() =>
      _FieldTeamNotificationsScreenState();
}

class _FieldTeamNotificationsScreenState
    extends State<FieldTeamNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const Color _blue = Color(0xFF4A80F0);
  static const Color _darkBlue = Color(0xFF0D47A1);

  static const List<Map<String, dynamic>> _allNotifs = [
    {
      'icon': Icons.assignment_turned_in_outlined,
      'iconColor': Color(0xFF4A80F0),
      'title': 'New Task Assigned',
      'body': 'Road Damage – NH-49',
      'time': '5 minutes ago',
      'type': 'task',
      'read': false,
    },
    {
      'icon': Icons.update_rounded,
      'iconColor': Colors.green,
      'title': 'Task Status Updated',
      'body': 'Pothole Report – SH-25',
      'time': '10 minutes ago',
      'type': 'task',
      'read': true,
    },
    {
      'icon': Icons.check_circle_outline,
      'iconColor': Colors.green,
      'title': 'Task Completed',
      'body': 'Street Light Out – Sector 12',
      'time': '1 hour ago',
      'type': 'task',
      'read': true,
    },
    {
      'icon': Icons.system_update_alt_rounded,
      'iconColor': Colors.orange,
      'title': 'System Update',
      'body': 'New features available',
      'time': '2 hours ago',
      'type': 'system',
      'read': true,
    },
    {
      'icon': Icons.alarm_rounded,
      'iconColor': Colors.red,
      'title': 'Reminder',
      'body': 'Update pending tasks',
      'time': '1 day ago',
      'type': 'system',
      'read': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filtered(String type) {
    if (type == 'All') return _allNotifs;
    return _allNotifs
        .where((n) => (n['type'] as String).toLowerCase() ==
            type.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications',
            style: TextStyle(
                color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: _blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: _blue,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Tasks'),
            Tab(text: 'System'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: ['All', 'task', 'system'].map((type) {
          final list = _filtered(type);
          return ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: list.length,
            itemBuilder: (context, i) {
              final n = list[i];
              return FadeInUp(
                delay: Duration(milliseconds: i * 60),
                child: _notifCard(n),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _notifCard(Map<String, dynamic> n) {
    final unread = !(n['read'] as bool);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFF0F5FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: unread
            ? Border.all(color: _blue.withOpacity(0.2))
            : Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (n['iconColor'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(n['icon'] as IconData,
                color: n['iconColor'] as Color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(n['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1A1A2E))),
                    ),
                    if (unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: _blue, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(n['body'],
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 5),
                Text(n['time'],
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
