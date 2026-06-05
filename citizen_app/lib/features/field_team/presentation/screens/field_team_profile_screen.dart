import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sadak_sevak_citizen/features/auth/data/auth_repository.dart';
import 'package:sadak_sevak_citizen/features/auth/presentation/screens/auth_screen.dart';
import 'task_history_screen.dart';
import 'field_team_settings_screen.dart';
import 'help_and_support_screen.dart';

class FieldTeamProfileScreen extends StatelessWidget {
  const FieldTeamProfileScreen({super.key});

  static const Color _blue = Color(0xFF4A80F0);
  static const Color _darkBlue = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Profile',
            style: TextStyle(
                color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ─── Profile Header ─────────────────────────────────────
            FadeInDown(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 48,
                          backgroundImage:
                              NetworkImage('https://i.pravatar.cc/150?img=12'),
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                              color: _blue, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text('Ramesh Kumar',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _darkBlue)),
                    const SizedBox(height: 4),
                    Text('Field Team Member',
                        style:
                            TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('ID: FT-2025-000',
                        style:
                            TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ─── Statistics ─────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 80),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
                padding: const EdgeInsets.all(16),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Statistics',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _darkBlue)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _stat('234', 'Total\nCompleted'),
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.grey.shade200),
                        _stat('45', 'This\nMonth'),
                        Container(
                            width: 1,
                            height: 36,
                            color: Colors.grey.shade200),
                        _stat('96%', 'Success\nRate'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ─── Menu Items ─────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 130),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 18),
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
                child: Column(
                  children: [
                    _menuTile(
                      icon: Icons.person_outline,
                      title: 'Personal Information',
                      onTap: () {},
                    ),
                    Divider(color: Colors.grey.shade100, height: 1),
                    _menuTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change Password',
                      onTap: () {},
                    ),
                    Divider(color: Colors.grey.shade100, height: 1),
                    _menuTile(
                      icon: Icons.settings_outlined,
                      title: 'App Settings',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const FieldTeamSettingsScreen())),
                    ),
                    Divider(color: Colors.grey.shade100, height: 1),
                    _menuTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const HelpAndSupportScreen())),
                    ),
                    Divider(color: Colors.grey.shade100, height: 1),
                    _menuTile(
                      icon: Icons.history_rounded,
                      title: 'Task History',
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const TaskHistoryScreen())),
                    ),
                    Divider(color: Colors.grey.shade100, height: 1),
                    _menuTile(
                      icon: Icons.info_outline_rounded,
                      title: 'About App',
                      onTap: () {},
                    ),
                    Divider(color: Colors.grey.shade100, height: 1),
                    _menuTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      color: Colors.red,
                      onTap: () async {
                        await AuthRepository().logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AuthScreen()),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _darkBlue)),
          const SizedBox(height: 3),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
        ],
      );

  Widget _menuTile({
    required IconData icon,
    required String title,
    Color color = const Color(0xFF0D47A1),
    required VoidCallback onTap,
  }) =>
      ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: color)),
        trailing: Icon(Icons.chevron_right_rounded,
            color: color.withOpacity(0.5), size: 20),
      );
}
