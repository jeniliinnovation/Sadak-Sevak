import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'government_field_operations_screen.dart';
import 'government_analytics_screen.dart';
import 'government_users_screen.dart';
import 'government_contractors_screen.dart';
import 'government_audit_logs_screen.dart';
import 'government_notifications_screen.dart';
import 'government_profile_screen.dart';
import 'government_settings_screen.dart';

class GovernmentMoreHubScreen extends StatelessWidget {
  const GovernmentMoreHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);

    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Field Operations',
        'subtitle': 'Live tracking & teams',
        'icon': Icons.map_rounded,
        'color': Colors.indigo,
        'screen': const GovernmentFieldOperationsScreen(),
      },
      {
        'title': 'Analytics & Reports',
        'subtitle': 'Statistics & insights',
        'icon': Icons.bar_chart_rounded,
        'color': Colors.blue.shade700,
        'screen': const GovernmentAnalyticsScreen(),
      },

      {
        'title': 'Contractors',
        'subtitle': 'Vendor directory & status',
        'icon': Icons.handyman_rounded,
        'color': Colors.deepOrange.shade600,
        'screen': const GovernmentContractorsScreen(),
      },
      {
        'title': 'Audit Logs',
        'subtitle': 'Trace system history',
        'icon': Icons.history_edu_rounded,
        'color': Colors.purple.shade600,
        'screen': const GovernmentAuditLogsScreen(),
      },
      {
        'title': 'Notifications',
        'subtitle': 'System alerts & warnings',
        'icon': Icons.notifications_active_rounded,
        'color': primaryOrange,
        'screen': const GovernmentNotificationsScreen(),
      },
      {
        'title': 'Profile',
        'subtitle': 'Account and contact details',
        'icon': Icons.person_pin_rounded,
        'color': Colors.amber.shade800,
        'screen': const GovernmentProfileScreen(),
      },
      {
        'title': 'System Settings',
        'subtitle': 'App configurations',
        'icon': Icons.settings_suggest_rounded,
        'color': Colors.blueGrey.shade600,
        'screen': const GovernmentSettingsScreen(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'More Operations',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInLeft(
              child: const Text(
                'Department Modules',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF263238),
                ),
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return FadeInUp(
                  duration: const Duration(milliseconds: 300),
                  delay: Duration(milliseconds: 40 * index),
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => item['screen']),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      splashColor: item['color'].withOpacity(0.05),
                      highlightColor: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade100),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.01),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: item['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                item['icon'],
                                color: item['color'],
                                size: 24,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF263238),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['subtitle'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
