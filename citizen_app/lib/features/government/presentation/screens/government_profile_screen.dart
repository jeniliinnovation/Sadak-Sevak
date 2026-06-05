import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sadak_sevak_citizen/features/auth/data/auth_repository.dart';
import 'package:sadak_sevak_citizen/features/auth/presentation/screens/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/auth/domain/user_model.dart';

class GovernmentProfileScreen extends StatefulWidget {
  const GovernmentProfileScreen({super.key});

  @override
  State<GovernmentProfileScreen> createState() => _GovernmentProfileScreenState();
}

class _GovernmentProfileScreenState extends State<GovernmentProfileScreen> {
  final _authRepo = AuthRepository();
  final _govRepo = GovernmentRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _deptController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = true;
  User? _user;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = await _govRepo.getProfile();
      setState(() {
        _user = user;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _deptController.text = user.role.replaceAll('_', ' ').toUpperCase();
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name') ?? 'User';
      final email = prefs.getString('user_email') ?? '';
      final role = prefs.getString('user_role') ?? 'citizen';
      setState(() {
        _user = User(id: prefs.getString('user_id') ?? '', name: name, email: email, role: role);
        _nameController.text = name;
        _emailController.text = email;
        _deptController.text = role.replaceAll('_', ' ').toUpperCase();
        _isLoading = false;
      });
    }
  }

  void _handleLogout() async {
    await _authRepo.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: primaryOrange))
        : SingleChildScrollView(
            child: Column(
              children: [
                // Gradient Header with overlapping avatar
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Gradient Background
                    Container(
                      height: 220,
                      margin: const EdgeInsets.only(bottom: 50),
                      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryOrange, Color(0xFFD84315)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout_rounded, color: Colors.white),
                            onPressed: _handleLogout,
                          )
                        ],
                      ),
                    ),
                    // Avatar
                    FadeInUp(
                      duration: const Duration(milliseconds: 400),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: _user?.avatar != null && _user!.avatar!.isNotEmpty 
                                  ? NetworkImage(_user!.avatar!) 
                                  : const NetworkImage('https://randomuser.me/api/portraits/men/33.jpg') as ImageProvider,
                              backgroundColor: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: primaryOrange, shape: BoxShape.circle),
                            child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                      Text(
                        _user?.name ?? 'Govt. Officer',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryOrange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _user?.role.toUpperCase() ?? 'ADMIN',
                          style: const TextStyle(color: primaryOrange, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
            const SizedBox(height: 36),

            // Form inputs
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade100, blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    _buildField('Full Name', _nameController, Icons.person_outline_rounded),
                    const SizedBox(height: 16),
                    _buildField('Email Address', _emailController, Icons.email_outlined),
                    const SizedBox(height: 16),
                    _buildField('Phone Number', _phoneController, Icons.phone_android_outlined),
                    const SizedBox(height: 16),
                    _buildField('Department', _deptController, Icons.business_outlined, isEnabled: false),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save / Edit Button
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_isEditing) {
                        _isEditing = false;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Profile saved successfully!'),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      } else {
                        _isEditing = true;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _isEditing ? 'Save Changes' : 'Edit Profile',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {bool isEnabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEnabled && _isEditing,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
            filled: true,
            fillColor: (isEnabled && _isEditing) ? const Color(0xFFFFF3E0).withOpacity(0.1) : Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF4511E)),
            ),
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: (isEnabled && _isEditing) ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
