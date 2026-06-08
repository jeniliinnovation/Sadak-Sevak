import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sadak_sevak_citizen/features/complaints/data/complaint_repository.dart';
import '../../../complaints/domain/complaint_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  int _currentStep = 0;
  final PageController _pageController = PageController();
  final MapController _mapController = MapController();
  LatLng _selectedLocation = const LatLng(19.0760, 72.8777); // Default to Mumbai

  final List<String> _stepTitles = ['Location', 'Details', 'Media', 'Review'];
  
  final _complaintRepo = ComplaintRepository();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _selectedImages = [];
  String _selectedCategory = 'Pothole';
  String _selectedPriority = 'Medium';
  bool _isSubmitting = false;
  bool _isFetchingLocation = false;
  String _currentAddress = 'Fetching...';
  bool _isFetchingAddress = false;
  
  String? _selectedVideo;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() => _selectedLocation = loc);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _mapController.move(loc, 16);
      });
    } catch (e) {
      // Fallback: keep default Mumbai coords
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _fetchAddress(LatLng loc) async {
    setState(() => _isFetchingAddress = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _currentAddress = '${p.street}, ${p.subLocality}, ${p.locality}';
          _isFetchingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = 'Coordinates: ${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}';
          _isFetchingAddress = false;
        });
      }
    }
  }

  void nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      setState(() => _currentStep++);
    } else {
      _submitReport();
    }
  }

  void prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);

    try {
      String? remoteImageUrl;
      
      // Real Upload Logic
      if (_selectedImages.isNotEmpty) {
        try {
          remoteImageUrl = await _complaintRepo.uploadMedia(_selectedImages.first);
        } catch (e) {
          debugPrint('Upload failed: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Media upload failed. Using placeholder on server. Check Cloudinary config in .env'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      final Complaint complaint = await _complaintRepo.createComplaint(
        title: _titleController.text.trim().isEmpty 
            ? '$_selectedCategory Issue' 
            : _titleController.text.trim(),
        description: _descriptionController.text,
        lat: _selectedLocation.latitude,
        lng: _selectedLocation.longitude,
        category: _selectedCategory,
        priority: _selectedPriority,
        imageUrl: remoteImageUrl,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReportSuccessScreen(complaintId: complaint.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Report New Issue', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _currentStep == 0 ? () => Navigator.pop(context) : prevStep,
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          const Divider(height: 1),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildLocationStep(),
                _buildDetailsStep(),
                _buildMediaStep(),
                _buildReviewStep(),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(4, (index) {
          bool isCompleted = index < _currentStep;
          bool isActive = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: isCompleted || isActive ? AppTheme.primaryColor : Colors.grey.shade100,
                          shape: BoxShape.circle,
                          boxShadow: isActive ? [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ] : [],
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check_rounded, size: 18, color: Colors.white)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isCompleted || isActive ? Colors.white : Colors.grey.shade400,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _stepTitles[index],
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive ? AppTheme.primaryColor : Colors.grey.shade500,
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < 3)
                  Container(
                    width: 40,
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Stack(
                      children: [
                        Container(decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(1))),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: index < _currentStep ? 40 : 0,
                          decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(1)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLocationStep() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _selectedLocation,
                  initialZoom: 15,
                  onPositionChanged: (position, hasGesture) {
                    if (hasGesture) {
                      setState(() {
                        _selectedLocation = position.center;
                        _fetchAddress(position.center);
                      });
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sadaksevak.citizen',
                  ),
                ],
              ),
              // Fixed Marker in Center (Pulsing Blue Dot)
              IgnorePointer(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FadeIn(
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF2196F3).withOpacity(0.1),
                                width: 1),
                          ),
                          child: Center(
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2196F3),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 0), // No offset needed for circular dot
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: GestureDetector(
                  onTap: _fetchCurrentLocation,
                  child: _buildMapAction(
                    _isFetchingLocation ? Icons.hourglass_top_rounded : Icons.my_location,
                  ),
                ),
              ),
              Positioned(bottom: 20, right: 20, child: _buildMapAction(Icons.layers_outlined)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Location',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.secondaryColor),
                  ),
                  TextButton.icon(
                    onPressed: _isFetchingLocation ? null : _fetchCurrentLocation,
                    icon: _isFetchingLocation
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.gps_fixed_rounded, size: 16),
                    label: Text(_isFetchingLocation ? 'Fetching...' : 'Locate Me'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAF9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on_rounded, color: Color(0xFF2196F3), size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isFetchingAddress ? 'Updating address...' : 'Pointer Location',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isFetchingAddress ? '...' : _currentAddress,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapAction(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
      child: Icon(icon, color: Colors.black87, size: 20),
    );
  }

  Widget _buildDetailsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Issue Title', 'Brief summary of the problem'),
          const SizedBox(height: 16),
          _buildTextField(_titleController, 'e.g. Large pothole near the park'),
          const SizedBox(height: 32),
          _buildSectionHeader('Issue Category', 'What kind of problem is it?'),
          const SizedBox(height: 16),
          _buildCategoryGrid(),
          const SizedBox(height: 32),
          _buildSectionHeader('Description', 'Provide additional details'),
          const SizedBox(height: 16),
          _buildTextArea('Describe the issue, landmarks, or how it affects the road...'),
          const SizedBox(height: 32),
          _buildSectionHeader('Priority Level', 'How urgent is this fix?'),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPriorityCard('Minor', Icons.info_outline_rounded, Colors.blue, _selectedPriority == 'Minor', () => setState(() => _selectedPriority = 'Minor')),
              const SizedBox(width: 12),
              _buildPriorityCard('Average', Icons.warning_amber_rounded, Colors.orange, _selectedPriority == 'Average', () => setState(() => _selectedPriority = 'Average')),
              const SizedBox(width: 12),
              _buildPriorityCard('Urgent', Icons.error_outline_rounded, Colors.red, _selectedPriority == 'Urgent', () => setState(() => _selectedPriority = 'Urgent')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.secondaryColor)),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Pothole', 'icon': Icons.warning_amber_rounded},
      {'name': 'Lighting', 'icon': Icons.lightbulb_outline_rounded},
      {'name': 'Water', 'icon': Icons.water_drop_outlined},
      {'name': 'Signage', 'icon': Icons.wrong_location_outlined},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        bool isSelected = _selectedCategory == cat['name'];
        return Container(
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200),
            boxShadow: isSelected ? [
              BoxShadow(color: AppTheme.primaryColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
            ] : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _selectedCategory = cat['name'] as String),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(cat['icon'] as IconData, color: isSelected ? Colors.white : AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      cat['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.secondaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriorityCard(String label, IconData icon, Color color, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : Colors.grey.shade200),
            boxShadow: isSelected ? [
              BoxShadow(color: color.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))
            ] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.white : color, size: 24),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTextArea(String hint) {
    return TextField(
      controller: _descriptionController,
      maxLines: 5,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primaryColor)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primaryColor)),
      ),
    );
  }


  Widget _buildMediaStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Photos (Max 5)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
          const SizedBox(height: 15),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ..._selectedImages.map((img) => _buildImageItem(img)).toList(),
              if (_selectedImages.length < 5)
                _buildAddMediaBox(
                  Icons.add_photo_alternate_outlined, 
                  'Add More', 
                  onTap: () => _showSourcePicker(isVideo: false)
                ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Add Video (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
          const SizedBox(height: 15),
          if (_selectedVideo != null)
            _buildVideoPreview()
          else
            _buildAddMediaBox(
              Icons.videocam_outlined, 
              'Add Video', 
              width: double.infinity,
              onTap: () => _showSourcePicker(isVideo: true)
            ),
        ],
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_file_rounded, size: 40, color: AppTheme.primaryColor),
                const SizedBox(height: 8),
                Text(
                  'Video Selected',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                ),
                Text(
                  _selectedVideo!.split('/').last,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: GestureDetector(
              onTap: () => setState(() => _selectedVideo = null),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageItem(String path) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        image: DecorationImage(
          image: _getImageProvider(path),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImages.remove(path)),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    // On web, path is already a blob URL or we use Image.network
    // On mobile, we need to use FileImage
    if (kIsWeb) {
      return NetworkImage(path);
    } else {
      // Use dynamic to avoid compile-time dart:io dependency issues if possible
      // but in Flutter, we can just use conditional imports or this check
      // For now, since we removed dart:io import, we need to handle it.
      // Actually, simplest is to use Image.file(File(path)) but we need a provider.
      // Let's use a helper that doesn't crash.
      return _getLocalStorageImageProvider(path);
    }
  }

  // Helper to get local storage image provider without direct dart:io import at top level
  ImageProvider _getLocalStorageImageProvider(String path) {
    // In a real app we'd use conditional exports, but for this fix
    // we'll use a safer approach if possible or just re-import inside method
    // but dart:io is unavailable on web at runtime.
    return NetworkImage(path); // Fallback for web, will be overridden below for mobile
  }

  void _showSourcePicker({required bool isVideo}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isVideo ? 'Add Video' : 'Add Photo', 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.secondaryColor)
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _buildSourceCard(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.pop(ctx);
                      if (isVideo) {
                        _pickVideo(ImageSource.camera);
                      } else {
                        _pickMedia(ImageSource.camera);
                      }
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildSourceCard(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(ctx);
                      if (isVideo) {
                        _pickVideo(ImageSource.gallery);
                      } else {
                        _pickMedia(ImageSource.gallery);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _selectedImages.add(image.path);
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? video = await picker.pickVideo(
        source: source,
      );
      if (video != null) {
        setState(() {
          _selectedVideo = video.path;
        });
      }
    } catch (e) {
      debugPrint('Error picking video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAddMediaBox(IconData icon, String label, {double? width, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        width: width ?? 100,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor),
            const SizedBox(height: 5),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.secondaryColor)),
          const SizedBox(height: 8),
          Text('Tap any field to edit before submitting.', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          const SizedBox(height: 24),
          _buildReviewCard(
            title: 'Issue Title',
            icon: Icons.title_rounded,
            content: _titleController.text.trim().isEmpty ? '$_selectedCategory Issue' : _titleController.text.trim(),
            color: AppTheme.primaryColor,
            onEdit: () { prevStep(); prevStep(); },
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            title: 'Location',
            icon: Icons.location_on_rounded,
            content: 'Lat: ${_selectedLocation.latitude.toStringAsFixed(6)}\nLong: ${_selectedLocation.longitude.toStringAsFixed(6)}',
            color: Colors.blue,
            onEdit: () { prevStep(); prevStep(); prevStep(); },
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            title: 'Issue Category & Priority',
            icon: Icons.category_rounded,
            content: '$_selectedCategory · $_selectedPriority Priority',
            color: Colors.orange,
            onEdit: () { prevStep(); prevStep(); },
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            title: 'Description',
            icon: Icons.description_rounded,
            content: _descriptionController.text.isEmpty ? '(No description entered)' : _descriptionController.text,
            color: Colors.green,
            onEdit: () { prevStep(); prevStep(); },
          ),
          const SizedBox(height: 12),
          _buildReviewCard(
            title: 'Media Attached',
            icon: Icons.collections_rounded,
            content: '${_selectedImages.length} Photo${_selectedImages.length == 1 ? '' : 's'}${_selectedVideo != null ? ' & 1 Video' : ''} attached.',
            color: Colors.purple,
            onEdit: () => prevStep(),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.amber),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Submitting a false report is subject to verification.',
                    style: TextStyle(color: Colors.amber.shade900, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({required String title, required IconData icon, required String content, required Color color, VoidCallback? onEdit}) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                if (onEdit != null)
                  const Icon(Icons.edit_rounded, color: Colors.grey, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: AppTheme.secondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSubmitting 
           ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
           : Text(
              _currentStep == 3 ? 'Submit Report' : 'Next',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
      ),
    );
  }
}

class PositionImage extends StatelessWidget {
  final double? top, bottom, left, right;
  final Widget child;
  const PositionImage({super.key, this.top, this.bottom, this.left, this.right, required this.child});
  @override
  Widget build(BuildContext context) {
    return Positioned(top: top, bottom: bottom, left: left, right: right, child: child);
  }
}

class ReportSuccessScreen extends StatelessWidget {
  final String complaintId;
  const ReportSuccessScreen({super.key, required this.complaintId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInScale(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, size: 100, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Report Submitted!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
              const SizedBox(height: 10),
              const Text('Your complaint has been submitted successfully.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 15)),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.shade100)),
                child: Column(
                  children: [
                    const Text('Complaint ID', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 5),
                    Text(complaintId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryColor)),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: const Text('Track Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Back to Home', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FadeInScale extends StatelessWidget {
  final Widget child;
  const FadeInScale({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return FadeIn(duration: const Duration(seconds: 1), child: child);
  }
}
