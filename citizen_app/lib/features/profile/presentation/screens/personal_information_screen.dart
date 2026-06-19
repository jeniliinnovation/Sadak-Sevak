import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:sadak_sevak_citizen/features/auth/data/auth_repository.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _authRepo = AuthRepository();
  bool _isEditing = false;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameCtrl.text = prefs.getString('user_name') ?? '';
      _emailCtrl.text = prefs.getString('user_email') ?? '';
      _phoneCtrl.text = prefs.getString('user_phone') ?? '';
      _addressCtrl.text = prefs.getString('user_address') ?? '';
    });

    try {
      final profile = await _authRepo.getProfile();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', profile.name);
      await prefs.setString('user_email', profile.email);
      setState(() {
        _nameCtrl.text = profile.name;
        _emailCtrl.text = profile.email;
      });
    } catch (_) {
      // Fallback to cached SharedPreferences values.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', _nameCtrl.text.trim());
    await prefs.setString('user_phone', _phoneCtrl.text.trim());
    await prefs.setString('user_address', _addressCtrl.text.trim());
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _isSaving = false;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text('Profile updated successfully!'),
            ],
          ),
          backgroundColor: AppTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

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
        title: const Text('Personal Information',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _isEditing
                ? (_isSaving ? null : _save)
                : () => setState(() => _isEditing = true),
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    _isEditing ? 'Save' : 'Edit',
                    style: TextStyle(
                      color: _isEditing ? AppTheme.primaryColor : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Avatar section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryColor, width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xFFE8F5EE),
                          child: Icon(Icons.person_rounded, size: 55, color: AppTheme.primaryColor),
                        ),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_nameCtrl.text.isEmpty ? 'Your Name' : _nameCtrl.text,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
                  const SizedBox(height: 4),
                  Text(_emailCtrl.text,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Form
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Account Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.secondaryColor)),
                    const SizedBox(height: 16),
                    _buildField('Full Name', Icons.person_outline_rounded, _nameCtrl,
                        enabled: _isEditing, validator: (v) => (v?.isEmpty ?? true) ? 'Name required' : null),
                    const SizedBox(height: 14),
                    _buildField('Email Address', Icons.email_outlined, _emailCtrl,
                        enabled: false, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _buildField('Phone Number', Icons.phone_outlined, _phoneCtrl,
                        enabled: _isEditing, keyboardType: TextInputType.phone,
                        hint: 'Add phone number'),
                    const SizedBox(height: 14),
                    _buildField('Home Address', Icons.home_outlined, _addressCtrl,
                        enabled: _isEditing, maxLines: 2, hint: 'Add home address'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Info card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your email address cannot be changed. Contact support for assistance.',
                      style: TextStyle(fontSize: 12, color: AppTheme.secondaryColor.withOpacity(0.7)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    IconData icon,
    TextEditingController ctrl, {
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade500, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          enabled: enabled,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppTheme.secondaryColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: enabled ? AppTheme.primaryColor : Colors.grey.shade400, size: 20),
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF8F8F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade100),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
