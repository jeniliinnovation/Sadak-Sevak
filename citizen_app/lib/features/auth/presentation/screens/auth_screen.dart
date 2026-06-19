import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:dio/dio.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:sadak_sevak_citizen/features/home/presentation/screens/main_layout.dart';
import 'package:sadak_sevak_citizen/features/contractor/presentation/screens/contractor_onboarding_screen.dart';
import '../../data/auth_repository.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool isLogin = true;
  bool isLoading = false;
  bool _passwordVisible = false;
  String _selectedRole = 'citizen'; // 'citizen' or 'contractor'
  final _authRepo = AuthRepository();
  late AnimationController _animController;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'john@gmail.com');
  final _passwordController = TextEditingController(text: 'user123');
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
      _selectedRole = 'citizen';
      if (!isLogin) {
        _emailController.clear();
        _passwordController.clear();
        _nameController.clear();
      } else {
        _emailController.text = 'john@gmail.com';
        _passwordController.text = 'user123';
      }
      _formKey.currentState?.reset();
    });
  }

  Future<void> _handleAuth() async {
    final state = _formKey.currentState;
    if (state == null || !state.validate()) return;
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (!isLogin && _selectedRole == 'contractor') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContractorOnboardingScreen(
            name: _nameController.text.trim(),
            email: email,
            password: password,
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = isLogin 
        ? await _authRepo.login(email, password)
        : await _authRepo.register(
            _nameController.text.trim(),
            email,
            password,
          );
          
        debugPrint('Auth Success: ${user.email} logged in with role: ${user.role}');
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainLayout(role: user.role)),
          );
        }
    } on DioException catch (e) {
      debugPrint('Auth Error: ${e.message}');
      debugPrint('Auth Data: ${e.response?.data}');
      if (mounted) {
        final message = e.response?.data?['error'] ?? 'Something went wrong. Please try again.';
        _showErrorSnack(message);
      }
    } catch (e) {
      debugPrint('Auth Unexpected Error: $e');
      if (mounted) _showErrorSnack('Unexpected error. Check your connection.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600))),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Back button (only in signup mode)
                if (!isLogin)
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: toggleAuthMode,
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22, color: AppTheme.secondaryColor),
                  ),

                const SizedBox(height: 16),

                // Green pill badge
                FadeInDown(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isLogin ? '👋  Welcome back!' : '🚀  Join Sadak-Sevak',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Title
                FadeInDown(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    isLogin ? 'Sign in to\nyour account' : 'Create a new\naccount',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                      height: 1.15,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeInDown(
                  delay: const Duration(milliseconds: 150),
                  child: Text(
                    isLogin
                        ? 'Enter your credentials to continue'
                        : 'Report road issues. Track progress. Make change.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  ),
                ),

                const SizedBox(height: 24),

                // Role selector toggle (signup only)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isLogin
                      ? const SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Account Type'),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildRoleSelector(
                                    role: 'citizen',
                                    label: 'Citizen',
                                    icon: Icons.person_outline_rounded,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildRoleSelector(
                                    role: 'contractor',
                                    label: 'Contractor',
                                    icon: Icons.engineering_outlined,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                ),

                // Name field (signup only)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isLogin
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Full Name'),
                          _buildTextFormField(
                            controller: _nameController,
                            hint: 'John Doe',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                ),

                // Email
                _buildLabel('Email Address'),
                _buildTextFormField(
                  controller: _emailController,
                  hint: 'john@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please enter your email';
                    if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                _buildLabel('Password'),
                _buildTextFormField(
                  controller: _passwordController,
                  hint: '••••••••',
                  icon: Icons.lock_outline_rounded,
                  isPassword: !_passwordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: Colors.grey.shade500,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'Password must be at least 6 characters' : null,
                ),

                // Forgot password
                if (isLogin)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: 28),

                // Main CTA button
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              isLogin 
                                  ? 'Sign In' 
                                  : (_selectedRole == 'contractor' ? 'Continue to Onboarding' : 'Create Account'),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Toggle login/signup
                Center(
                  child: GestureDetector(
                    onTap: toggleAuthMode,
                    child: Text.rich(
                      TextSpan(
                        text: isLogin ? "Don't have an account?  " : "Already have an account?  ",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        children: [
                          TextSpan(
                            text: isLogin ? 'Sign Up' : 'Login',
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Demo credentials hint
                if (isLogin)
                  FadeIn(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.tips_and_updates_rounded, color: AppTheme.primaryColor, size: 16),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Test Credentials',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _credRow('Citizen', 'john@gmail.com', 'user123'),
                          const SizedBox(height: 4),
                          _credRow('Admin', 'admin@sadaksevak.com', 'admin123'),
                          const SizedBox(height: 4),
                          _credRow('Team', 'priya.mehta@gov.in', 'gov123'),
                          const SizedBox(height: 4),
                          _credRow('Govt', 'ravi.kumar@gov.in', 'gov123'),
                          const SizedBox(height: 4),
                          _credRow('Contractor', 'rajesh.contractor@builder.in', 'contract123'),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _credRow(String role, String email, String pass) {
    return GestureDetector(
      onTap: () {
        _emailController.text = email;
        _passwordController.text = pass;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(role.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$email / $pass',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 11, letterSpacing: -0.2),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.touch_app_outlined, size: 14, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF8FAFB),
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
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildRoleSelector({
    required String role,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

