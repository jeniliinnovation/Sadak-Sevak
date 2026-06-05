import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

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
        title: const Text('Help & Support',
            style: TextStyle(
                color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Quick Help ─────────────────────────────────────────
            FadeInDown(
              child: _sectionTitle('Quick Help'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 60),
              child: _card(children: [
                _helpTile(Icons.report_outlined, 'How to Report Issue',
                    () {}),
                Divider(color: Colors.grey.shade100, height: 1),
                _helpTile(Icons.update_rounded, 'Update Task Status',
                    () {}),
                Divider(color: Colors.grey.shade100, height: 1),
                _helpTile(Icons.wifi_off_rounded, 'Offline Mode Guide',
                    () {}),
                Divider(color: Colors.grey.shade100, height: 1),
                _helpTile(Icons.sync_rounded, 'Sync Data', () {}),
              ]),
            ),

            const SizedBox(height: 20),

            // ─── Contact Support ────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 120),
              child: _sectionTitle('Contact Support'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: _card(children: [
                _helpTile(
                  Icons.phone_outlined,
                  'Call Support',
                  () async {
                    final uri = Uri(scheme: 'tel', path: '+911800123456');
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  },
                ),
                Divider(color: Colors.grey.shade100, height: 1),
                _helpTile(
                  Icons.chat_bubble_outline_rounded,
                  'WhatsApp Support',
                  () {},
                ),
                Divider(color: Colors.grey.shade100, height: 1),
                _helpTile(
                  Icons.email_outlined,
                  'Email Support',
                  () async {
                    final uri = Uri(
                        scheme: 'mailto',
                        path: 'support@sadaksevak.in');
                    if (await canLaunchUrl(uri)) launchUrl(uri);
                  },
                ),
              ]),
            ),

            const SizedBox(height: 20),

            // ─── App Information ────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _sectionTitle('App Information'),
            ),
            FadeInUp(
              delay: const Duration(milliseconds: 230),
              child: _card(children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEEF3FF),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.info_outline_rounded,
                        color: _blue, size: 20),
                  ),
                  title: const Text('Version',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E))),
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

  Widget _card({required List<Widget> children}) => Container(
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

  Widget _helpTile(IconData icon, String title, VoidCallback onTap) =>
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
        trailing: const Icon(Icons.chevron_right_rounded,
            color: Colors.grey, size: 18),
      );
}
