import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sadak_sevak_citizen/features/auth/data/auth_repository.dart';
import 'package:sadak_sevak_citizen/features/auth/presentation/screens/auth_screen.dart';
import 'package:sadak_sevak_citizen/features/home/presentation/screens/notifications_screen.dart';

import 'personal_information_screen.dart';
import 'my_contributions_screen.dart';
import 'saved_locations_screen.dart';
import 'security_privacy_screen.dart';
import 'change_password_screen.dart';
import 'language_screen.dart';
import 'help_faq_screen.dart';
import 'about_sadak_sevak_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Citizen';
  String _email = 'email@example.com';
  String _userId = 'ID: #SEVAK2026';
  final _authRepo = AuthRepository();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'Citizen';
      _email = prefs.getString('user_email') ?? 'email@example.com';
      final rawId = prefs.getString('user_id') ?? '2026';
      _userId = 'ID: #SEVAK${rawId.substring(0, 4).toUpperCase()}';
    });

    try {
      final profile = await AuthRepository().getProfile();
      setState(() {
        _name = profile.name;
        _email = profile.email;
        _userId = 'ID: #SEVAK${profile.id.substring(0, 4).toUpperCase()}';
      });
    } catch (_) {
      // Keep cached profile if backend fetch fails.
    }
  }

  Future<void> _handleLogout() async {
    // Confirm first
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Logout', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authRepo.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Profile', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PersonalInformationScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSectionTitle('Accounts'),
            _buildProfileItem(
              context,
              Icons.person_outline_rounded,
              'Personal Information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PersonalInformationScreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              Icons.volunteer_activism_outlined,
              'My Contributions',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyContributionsScreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              Icons.location_on_outlined,
              'Saved Locations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedLocationsScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildSectionTitle('Settings'),
            _buildProfileItem(
              context,
              Icons.notifications_none_rounded,
              'Notifications',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              Icons.security_outlined,
              'Security & Privacy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SecurityPrivacyScreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              Icons.lock_outline_rounded,
              'Change Password',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            _buildProfileItem(
              context, 
              Icons.language_rounded, 
              'Language',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LanguageScreen()),
                );
              },
            ),
            const SizedBox(height: 10),
            _buildSectionTitle('Support'),
            _buildProfileItem(
              context,
              Icons.help_outline_rounded,
              'Help & FAQ',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpFAQScreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              Icons.info_outline_rounded,
              'About Sadak-Sevak',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutSadakSevakScreen()),
                );
              },
            ),
            _buildProfileItem(
              context,
              Icons.logout_rounded,
              'Logout',
              color: Colors.red,
              onTap: _handleLogout,
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade400,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.primaryColor,
              child: Icon(Icons.person, color: Colors.white, size: 36),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _userId,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _email,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.edit_note_rounded,
              color: AppTheme.primaryColor,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String title, {
    Color color = Colors.black87,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color == Colors.red
              ? Colors.red.withOpacity(0.1)
              : AppTheme.primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: color == Colors.red ? Colors.red : AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
          fontSize: 15,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Colors.grey.shade400,
      ),
      onTap: onTap ?? () {},
    );
  }
}
