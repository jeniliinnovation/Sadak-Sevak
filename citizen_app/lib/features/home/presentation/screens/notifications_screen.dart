import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Complaint Accepted',
        'desc': 'Your complaint #CMP12345 has been accepted.',
        'time': '10 min ago',
        'icon': Icons.check_circle_outline,
        'color': Colors.blue
      },
      {
        'title': 'Work Started',
        'desc': 'Update: Work has started on #CMP12345.',
        'time': '2 hours ago',
        'icon': Icons.engineering_outlined,
        'color': Colors.orange
      },
      {
        'title': 'Issue Resolved',
        'desc': 'Your complaint #CMP12343 has been resolved!',
        'time': '1 day ago',
        'icon': Icons.celebration_outlined,
        'color': Colors.green
      },
       {
        'title': 'New Update',
        'desc': 'New update on your followed issue #CMP98765.',
        'time': '2 days ago',
        'icon': Icons.info_outline,
        'color': Colors.grey
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Notifications', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Mark all as read', style: TextStyle(fontSize: 12))),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 100),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notify = notifications[index];
          return FadeInUp(
            delay: Duration(milliseconds: 100 * index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (notify['color'] as Color).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(notify['icon'] as IconData, color: notify['color'] as Color, size: 20),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(notify['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(notify['time'] as String, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          notify['desc'] as String,
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
