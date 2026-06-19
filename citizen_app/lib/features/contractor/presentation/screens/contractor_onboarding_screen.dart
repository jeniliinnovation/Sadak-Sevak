import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:sadak_sevak_citizen/features/auth/data/auth_repository.dart';
import 'package:sadak_sevak_citizen/features/home/presentation/screens/main_layout.dart';

class ContractorOnboardingScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const ContractorOnboardingScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<ContractorOnboardingScreen> createState() => _ContractorOnboardingScreenState();
}

class _ContractorOnboardingScreenState extends State<ContractorOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _addressController = TextEditingController();
  final _mobileController = TextEditingController();
  final _portfolioUrlController = TextEditingController();

  final _authRepo = AuthRepository();
  bool _isLoading = false;
  final _picker = ImagePicker();

  // Selected portfolio assets
  String? _selectedPdfName;
  String? _selectedPdfSize;
  List<String> _selectedImages = [];

  // Pre-defined sample PDFs for simulation
  final List<Map<String, String>> _samplePdfs = [
    {'name': 'sadak_sevak_road_portfolio_2026.pdf', 'size': '4.8 MB'},
    {'name': 'national_highways_experience_cert.pdf', 'size': '2.1 MB'},
    {'name': 'metro_infrastructure_license.pdf', 'size': '3.5 MB'},
  ];

  // Pre-defined sample images for easy mock selection
  final List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=500&auto=format&fit=crop&q=60', // worker
    'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=500&auto=format&fit=crop&q=60', // asphalt road
    'https://images.unsplash.com/photo-1581094288338-2314dddb7eed?w=500&auto=format&fit=crop&q=60', // machinery
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=500&auto=format&fit=crop&q=60', // site
    'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=500&auto=format&fit=crop&q=60', // road painting
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _mobileController.dispose();
    _portfolioUrlController.dispose();
    super.dispose();
  }

  // Choose a mock PDF Portfolio
  void _pickPdf() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select PDF Portfolio',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose one of the validated documents to simulate a PDF upload:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ..._samplePdfs.map((pdf) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade50,
                      child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                    ),
                    title: Text(
                      pdf['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(pdf['size']!, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                    onTap: () {
                      setState(() {
                        _selectedPdfName = pdf['name'];
                        _selectedPdfSize = pdf['size'];
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // Handle adding images
  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add Portfolio Image',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Upload using camera/gallery, or use template site photographs:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildUploadOption(
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      onTap: () async {
                        Navigator.pop(context);
                        final image = await _picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          setState(() => _selectedImages.add(image.path));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUploadOption(
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      onTap: () async {
                        Navigator.pop(context);
                        final image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() => _selectedImages.add(image.path));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Template Road Construction Photos',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleImages.length,
                  itemBuilder: (context, index) {
                    final imgUrl = _sampleImages[index];
                    final isAlreadySelected = _selectedImages.contains(imgUrl);
                    return GestureDetector(
                      onTap: () {
                        if (isAlreadySelected) {
                          setState(() => _selectedImages.remove(imgUrl));
                        } else {
                          setState(() => _selectedImages.add(imgUrl));
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAlreadySelected ? AppTheme.primaryColor : Colors.grey.shade300,
                            width: isAlreadySelected ? 3 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(imgUrl, fit: BoxFit.cover),
                              if (isAlreadySelected)
                                Container(
                                  color: Colors.black.withOpacity(0.4),
                                  child: const Icon(Icons.check, color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 28),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // Handle Form Submission
  Future<void> _submitOnboarding() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    // Validate that at least one portfolio item is provided
    final hasUrl = _portfolioUrlController.text.trim().isNotEmpty;
    final hasPdf = _selectedPdfName != null;
    final hasImages = _selectedImages.isNotEmpty;

    if (!hasUrl && !hasPdf && !hasImages) {
      _showErrorSnack('Please provide at least one portfolio item: a Website Link, a PDF document, or at least 1 Image.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Register in backend
      final user = await _authRepo.register(
        _nameController.text.trim(),
        widget.email,
        widget.password,
        role: 'contractor',
      );

      // Save additional onboarding info locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_address', _addressController.text.trim());
      await prefs.setString('user_mobile', _mobileController.text.trim());
      await prefs.setString('user_portfolio_url', _portfolioUrlController.text.trim());
      await prefs.setString('user_portfolio_pdf', _selectedPdfName ?? '');
      await prefs.setStringList('user_portfolio_images', _selectedImages);

      if (mounted) {
        // Show success and go to main contractor dashboard
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contractor Onboarding Completed Successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainLayout(role: user.role)),
          (route) => false,
        );
      }
    } on DioException catch (e) {
      final message = e.response?.data?['error'] ?? 'Registration failed. Please try again.';
      _showErrorSnack(message);
    } catch (e) {
      _showErrorSnack('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.secondaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Contractor Onboarding',
          style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Registering as a Contractor',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Complete the forms and submit your portfolio documents for approval.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 28),

                  _buildSectionTitle('1. Basic Details'),
                  const SizedBox(height: 12),
                  _buildLabel('Full / Company Name'),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'ABC Construction Ltd',
                    icon: Icons.business_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Company Name is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Contact Address'),
                  _buildTextField(
                    controller: _addressController,
                    hint: 'Sector 4, Main Street, Rajkot',
                    icon: Icons.location_on_outlined,
                    maxLines: 2,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Mobile Number'),
                  _buildTextField(
                    controller: _mobileController,
                    hint: '9876543210',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Mobile number is required';
                      if (v.trim().length != 10 || int.tryParse(v) == null) {
                        return 'Enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),
                  _buildSectionTitle('2. Work & Experience'),
                  const SizedBox(height: 12),
                  _buildLabel('Portfolio Website Link'),
                  _buildTextField(
                    controller: _portfolioUrlController,
                    hint: 'https://www.abcbuilders.com',
                    icon: Icons.link_outlined,
                    keyboardType: TextInputType.url,
                    validator: (v) {
                      if (v != null && v.trim().isNotEmpty) {
                        if (!v.startsWith('http://') && !v.startsWith('https://')) {
                          return 'URL must start with http:// or https://';
                        }
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 28),
                  _buildSectionTitle('3. Upload Credentials'),
                  const SizedBox(height: 6),
                  const Text(
                    'Provide 1 PDF document and at least 3 site images in PNG/JPG.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),

                  // PDF Selector
                  _buildLabel('Portfolio Document (PDF)'),
                  const SizedBox(height: 8),
                  if (_selectedPdfName == null)
                    _buildDashedPicker(
                      icon: Icons.picture_as_pdf_outlined,
                      label: 'Upload PDF Portfolio',
                      onTap: _pickPdf,
                    )
                  else
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.red.shade100, width: 1.5),
                      ),
                      color: Colors.red.shade50.withOpacity(0.3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.picture_as_pdf, color: Colors.red, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedPdfName!,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedPdfSize!,
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedPdfName = null;
                                  _selectedPdfSize = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Site Images Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLabel('Site Verification Images (Min. 3)'),
                      Text(
                        '${_selectedImages.length} selected',
                        style: TextStyle(
                          color: _selectedImages.length >= 3 ? AppTheme.primaryColor : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _selectedImages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _selectedImages.length) {
                        return _buildDashedPickerSquare(onTap: _showImagePickerDialog);
                      }

                      final path = _selectedImages[index];
                      final isNetwork = path.startsWith('http');

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: isNetwork
                                  ? Image.network(path, fit: BoxFit.cover)
                                  : Image.asset(path, fit: BoxFit.cover), // Handles local asset or picked path
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedImages.removeAt(index)),
                              child: Container(
                                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close, color: Colors.white, size: 14),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Submit CTA
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitOnboarding,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor: AppTheme.primaryColor.withOpacity(0.6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Submit Onboarding Application',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey.shade500, size: 20),
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

  Widget _buildDashedPicker({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), // simulating dashed via grey solid
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 2),
            const Text('Tap to choose file', style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedPickerSquare({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade600, size: 24),
            const SizedBox(height: 4),
            const Text(
              'Add Photo',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
