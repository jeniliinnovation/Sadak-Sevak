import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class FieldTeamSettingsScreen extends StatefulWidget {
  const FieldTeamSettingsScreen({super.key});

  @override
  State<FieldTeamSettingsScreen> createState() =>
      _FieldTeamSettingsScreenState();
}

class _FieldTeamSettingsScreenState
    extends State<FieldTeamSettingsScreen> {
  bool _autoSync = true;
  bool _pushNotifications = true;
  bool _locationServices = true;
  String _language = 'English';
  String _theme = 'Light';

  static const Color _blue = Color(0xFF4A80F0);
  static const Color _darkBlue = Color(0xFF0D47A1);

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
        title: const Text('Settings',
            style: TextStyle(
                color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── App Settings ───────────────────────────────────────
            FadeInDown(
              child: _sectionTitle('App Settings'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 60),
              child: _settingsCard(children: [
                _dropdownTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  value: _language,
                  options: ['English', 'Hindi', 'Marathi'],
                  onChanged: (v) => setState(() => _language = v!),
                ),
                Divider(color: Colors.grey.shade100, height: 1),
                _dropdownTile(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  value: _theme,
                  options: ['Light', 'Dark', 'System'],
                  onChanged: (v) => setState(() => _theme = v!),
                ),
              ]),
            ),

            const SizedBox(height: 18),

            // ─── Data Settings ──────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _sectionTitle('Data Settings'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 130),
              child: _settingsCard(children: [
                _switchTile(
                  icon: Icons.sync_rounded,
                  title: 'Auto Sync',
                  subtitle: 'Wi-Fi Only',
                  value: _autoSync,
                  onChanged: (v) => setState(() => _autoSync = v),
                ),
                Divider(color: Colors.grey.shade100, height: 1),
                _actionTile(
                  icon: Icons.map_outlined,
                  title: 'Offline Maps',
                  trailing: TextButton(
                    onPressed: () {},
                    child: const Text('Download',
                        style: TextStyle(color: _blue, fontSize: 13)),
                  ),
                ),
              ]),
            ),

            const SizedBox(height: 18),

            // ─── Other Settings ─────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 170),
              child: _sectionTitle('Other Settings'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _settingsCard(children: [
                _switchTile(
                  icon: Icons.notifications_outlined,
                  title: 'Push Notifications',
                  value: _pushNotifications,
                  onChanged: (v) =>
                      setState(() => _pushNotifications = v),
                ),
                Divider(color: Colors.grey.shade100, height: 1),
                _switchTile(
                  icon: Icons.location_on_outlined,
                  title: 'Location Services',
                  value: _locationServices,
                  onChanged: (v) =>
                      setState(() => _locationServices = v),
                ),
                Divider(color: Colors.grey.shade100, height: 1),
                _actionTile(
                  icon: Icons.delete_sweep_outlined,
                  title: 'Clear Cache',
                  trailing: Text('25.4 MB',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13)),
                  onTap: () {},
                ),
              ]),
            ),

            const SizedBox(height: 18),

            // ─── App Info ───────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 240),
              child: _sectionTitle('App Information'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 270),
              child: _settingsCard(children: [
                _actionTile(
                  icon: Icons.info_outline_rounded,
                  title: 'Version',
                  trailing: Text('1.0.0',
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13)),
                ),
              ]),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 2),
        child: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF6B7280),
                letterSpacing: 0.5)),
      );

  Widget _settingsCard({required List<Widget> children}) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(children: children),
      );

  Widget _switchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) =>
      ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color(0xFFEEF3FF),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: _blue, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1A1A2E))),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: TextStyle(
                    color: Colors.grey.shade500, fontSize: 11))
            : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: _blue,
        ),
      );

  Widget _dropdownTile({
    required IconData icon,
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) =>
      ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color(0xFFEEF3FF),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: _blue, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1A1A2E))),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            items: options
                .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                .toList(),
            onChanged: onChanged,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
        ),
      );

  Widget _actionTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) =>
      ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: const Color(0xFFEEF3FF),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: _blue, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF1A1A2E))),
        trailing: trailing,
      );
}
