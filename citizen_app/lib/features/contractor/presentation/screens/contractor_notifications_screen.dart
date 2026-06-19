import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';

class ContractorNotificationsScreen extends StatelessWidget {
  const ContractorNotificationsScreen({super.key});

  final List<Map<String, String>> _notifications = const [
    {
      'title': 'New Inspection Assigned',
      'subtitle': 'Bridge repair at Riverfront Road needs confirmation',
      'time': '2h ago',
    },
    {
      'title': 'Approval Received',
      'subtitle': 'Pothole fix on MG Road has been approved by supervisor',
      'time': '5h ago',
    },
    {
      'title': 'Safety Reminder',
      'subtitle': 'Wear visibility gear when working after 7 PM.',
      'time': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Alerts', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        itemCount: _notifications.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _notifications[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              leading: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryColor),
              ),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['subtitle']!, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              trailing: Text(item['time']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          );
        },
      ),
    );
  }
}
