import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:sadak_sevak_citizen/features/auth/data/auth_repository.dart';
import 'package:sadak_sevak_citizen/features/auth/presentation/screens/auth_screen.dart';

class ContractorProfileScreen extends StatefulWidget {
  const ContractorProfileScreen({super.key});

  @override
  State<ContractorProfileScreen> createState() => _ContractorProfileScreenState();
}

class _ContractorProfileScreenState extends State<ContractorProfileScreen> {
  String _name = 'Contractor';
  String _email = 'contractor@example.com';
  String _role = 'contractor';
  String _address = 'Sector 4, Main Street, Rajkot';
  String _mobile = '9876543210';
  String _portfolioUrl = 'https://www.contractorportfolio.in';
  String _portfolioPdf = 'sadak_sevak_road_portfolio_2026.pdf';
  List<String> _portfolioImages = [];
  final _authRepo = AuthRepository();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('user_name') ?? 'Contractor';
      _email = prefs.getString('user_email') ?? 'contractor@example.com';
      _role = prefs.getString('user_role') ?? 'contractor';
      _address = prefs.getString('user_address') ?? 'Sector 4, Main Street, Rajkot';
      _mobile = prefs.getString('user_mobile') ?? '9876543210';
      _portfolioUrl = prefs.getString('user_portfolio_url') ?? 'https://www.contractorportfolio.in';
      _portfolioPdf = prefs.getString('user_portfolio_pdf') ?? 'sadak_sevak_road_portfolio_2026.pdf';
      _portfolioImages = prefs.getStringList('user_portfolio_images') ?? [
        'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=500',
        'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=500',
        'https://images.unsplash.com/photo-1581094288338-2314dddb7eed?w=500'
      ];
    });
  }

  Future<void> _logout() async {
    await _authRepo.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = false;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: const SizedBox.shrink(), // Remove back button space since it is a tab
        title: Text(
          'Profile',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_outlined, color: AppTheme.primaryColor, size: 28),
            onPressed: _showEditProfileBottomSheet,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                    child: const Icon(Icons.engineering_rounded, color: AppTheme.primaryColor, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _email,
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.green.shade900.withOpacity(0.4) : const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _role.toUpperCase(),
                            style: TextStyle(
                              color: isDark ? Colors.green.shade300 : const Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection('My Account', [
              _buildProfileTile(Icons.work_outline_rounded, 'Assigned Projects', 'View all active projects', onTap: () {}),
              _buildProfileTile(Icons.history_rounded, 'Activity Log', 'Track completed jobs', onTap: () {}),
            ]),
            const SizedBox(height: 20),
            _buildSection('Portfolio & Credentials', [
              _buildPortfolioCard(),
            ]),
            const SizedBox(height: 20),
            _buildSection('Support', [
              _buildProfileTile(Icons.help_outline, 'Help Center', 'Get support for your work orders', onTap: () {}),
              _buildProfileTile(Icons.info_outline, 'About Sadak-Sevak', 'Learn more about the platform', onTap: () {}),
            ]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text('Logout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    final isDark = false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildProfileTile(IconData icon, String title, String subtitle, {required VoidCallback onTap}) {
    final isDark = false;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.grey.shade400 : Colors.grey,
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: isDark ? Colors.grey.shade500 : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildPortfolioCard() {
    final isDark = false;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPortfolioRow(Icons.location_on_outlined, 'Address', _address),
          Divider(height: 24, color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
          _buildPortfolioRow(Icons.phone_outlined, 'Mobile', _mobile),
          Divider(height: 24, color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
          _buildPortfolioRow(
            Icons.link_outlined,
            'Website',
            _portfolioUrl,
            isLink: true,
          ),
          Divider(height: 24, color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
          Text(
            'Verification Document',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade400 : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? Colors.red.shade900.withOpacity(0.2) : Colors.red.shade50.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.red.shade800.withOpacity(0.5) : Colors.red.shade100),
            ),
            child: Row(
              children: [
                const Icon(Icons.picture_as_pdf, color: Colors.red, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _portfolioPdf.isNotEmpty ? _portfolioPdf : 'portfolio_document.pdf',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.download_rounded, color: isDark ? Colors.grey.shade400 : Colors.grey, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Site Images',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey.shade400 : Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _portfolioImages.length,
              itemBuilder: (context, index) {
                final path = _portfolioImages[index];
                final isNetwork = path.startsWith('http');
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: isNetwork
                        ? Image.network(path, fit: BoxFit.cover)
                        : Image.asset(path, fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioRow(IconData icon, String label, String value, {bool isLink = false}) {
    final isDark = false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isLink ? AppTheme.primaryColor : (isDark ? Colors.white : AppTheme.secondaryColor),
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfileBottomSheet() {
    final nameController = TextEditingController(text: _name);
    final addressController = TextEditingController(text: _address);
    final mobileController = TextEditingController(text: _mobile);
    final portfolioUrlController = TextEditingController(text: _portfolioUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Profile Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildEditLabel('Company / Contractor Name'),
                TextFormField(
                  controller: nameController,
                  decoration: _buildEditInputDec('Enter name'),
                ),
                const SizedBox(height: 12),
                _buildEditLabel('Phone Number'),
                TextFormField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: _buildEditInputDec('Enter mobile number'),
                ),
                const SizedBox(height: 12),
                _buildEditLabel('Office Address'),
                TextFormField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: _buildEditInputDec('Enter address'),
                ),
                const SizedBox(height: 12),
                _buildEditLabel('Website URL'),
                TextFormField(
                  controller: portfolioUrlController,
                  keyboardType: TextInputType.url,
                  decoration: _buildEditInputDec('Enter website URL'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('user_name', nameController.text.trim());
                      await prefs.setString('user_mobile', mobileController.text.trim());
                      await prefs.setString('user_address', addressController.text.trim());
                      await prefs.setString('user_portfolio_url', portfolioUrlController.text.trim());

                      setState(() {
                        _name = nameController.text.trim();
                        _mobile = mobileController.text.trim();
                        _address = addressController.text.trim();
                        _portfolioUrl = portfolioUrlController.text.trim();
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile updated successfully!'),
                            backgroundColor: AppTheme.primaryColor,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEditLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.secondaryColor),
      ),
    );
  }

  InputDecoration _buildEditInputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    );
  }
}
