import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';

import 'change_password_screen.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _biometricLogin = false;
  bool _shareLocation = true;
  bool _analyticsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.secondaryColor),
        ),
        title: const Text('Security & Privacy',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Security Settings'),
          _buildToggleItem(
            'Biometric Login',
            'Use FaceID/Fingerprint to log into the app',
            Icons.fingerprint_rounded,
            _biometricLogin,
            (val) => setState(() => _biometricLogin = val),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Change Password',
            'Update your account password regularly',
            Icons.lock_outline_rounded,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Privacy Options'),
          _buildToggleItem(
            'Location Sharing',
            'Allow app to access high-accuracy GPS for reporting issues',
            Icons.location_on_outlined,
            _shareLocation,
            (val) => setState(() => _shareLocation = val),
          ),
          const SizedBox(height: 12),
          _buildToggleItem(
            'Usage Analytics',
            'Share anonymous logs to help improve the system',
            Icons.analytics_outlined,
            _analyticsEnabled,
            (val) => setState(() => _analyticsEnabled = val),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Request Account Data',
            'Download a copy of your personal data',
            Icons.download_outlined,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account data request submitted. You will receive an email shortly.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            'Delete Account',
            'Permanently delete your profile and logs',
            Icons.delete_forever_rounded,
            () {
              _showDeleteAccountDialog();
            },
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade400, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildToggleItem(String title, String desc, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryColor,
          secondary: Icon(icon, color: AppTheme.primaryColor),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 14)),
          subtitle: Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, String desc, IconData icon, VoidCallback onTap, {Color color = AppTheme.secondaryColor}) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade100)),
      child: ListTile(
        leading: Icon(icon, color: color == Colors.red ? Colors.red : AppTheme.primaryColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        subtitle: Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPass = TextEditingController();
    final newPass = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPass,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully!'),
                  backgroundColor: AppTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Change'),
          )
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: const Text('Are you sure you want to permanently delete your account? This action is irreversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              // Handle account deletion logic / logout
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }
}
