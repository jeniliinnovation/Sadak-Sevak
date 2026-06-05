import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class GovernmentSettingsScreen extends StatefulWidget {
  const GovernmentSettingsScreen({super.key});

  @override
  State<GovernmentSettingsScreen> createState() => _GovernmentSettingsScreenState();
}

class _GovernmentSettingsScreenState extends State<GovernmentSettingsScreen> {
  bool _pushNotifications = true;
  bool _emailAlerts = false;
  bool _autoBackup = true;

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'System Settings',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences Group
            _buildSectionHeader('Preferences'),
            FadeInUp(
              duration: const Duration(milliseconds: 300),
              delay: const Duration(milliseconds: 100),
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSwitchTile('Push Notifications', 'Receive real-time alerts', Icons.notifications_active_rounded, _pushNotifications, (val) => setState(() => _pushNotifications = val)),
                    _buildDivider(),
                    _buildSwitchTile('Email Summaries', 'Daily digest of system activities', Icons.email_rounded, _emailAlerts, (val) => setState(() => _emailAlerts = val)),
                  ],
                ),
              ),
            ),

            // Management Group
            _buildSectionHeader('Management'),
            FadeInUp(
              duration: const Duration(milliseconds: 300),
              delay: const Duration(milliseconds: 200),
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildActionTile('Departments', 'Manage internal department lists', Icons.corporate_fare_rounded),
                    _buildDivider(),
                    _buildActionTile('Work Categories', 'Update project categories', Icons.construction_rounded),
                    _buildDivider(),
                    _buildActionTile('Complaint Types', 'Configure citizen complaint types', Icons.report_problem_rounded),
                  ],
                ),
              ),
            ),

            // Advanced Group
            _buildSectionHeader('Advanced'),
            FadeInUp(
              duration: const Duration(milliseconds: 300),
              delay: const Duration(milliseconds: 300),
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSwitchTile('Automated Backups', 'Nightly database backups', Icons.backup_rounded, _autoBackup, (val) => setState(() => _autoBackup = val)),
                    _buildDivider(),
                    _buildActionTile('System Logs', 'View technical diagnostic logs', Icons.terminal_rounded),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            // Footer Version
            Center(
              child: Text(
                'Sadak Sevak Admin v1.0.4',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 64, endIndent: 20);
  }

  Widget _buildActionTile(String title, String desc, IconData icon) {
    const primaryOrange = Color(0xFFF4511E);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: primaryOrange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: primaryOrange, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF263238))),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(desc, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
      trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade300, size: 16),
      onTap: () {},
    );
  }

  Widget _buildSwitchTile(String title, String desc, IconData icon, bool value, ValueChanged<bool> onChanged) {
    const primaryOrange = Color(0xFFF4511E);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: value ? primaryOrange.withOpacity(0.1) : Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: value ? primaryOrange : Colors.grey.shade600, size: 24),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF263238))),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(desc, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: primaryOrange,
      ),
    );
  }
}
