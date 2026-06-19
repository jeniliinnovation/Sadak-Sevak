import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import '../../data/contractor_repository.dart';

class ContractorUpdateProgressScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  final Function(int progress, String status) onUpdate;

  const ContractorUpdateProgressScreen({
    super.key,
    required this.project,
    required this.onUpdate,
  });

  @override
  State<ContractorUpdateProgressScreen> createState() => _ContractorUpdateProgressScreenState();
}

class _ContractorUpdateProgressScreenState extends State<ContractorUpdateProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  late double _progressValue;
  late String _statusValue; // 'Work Started', 'In Progress', 'Near Completion'
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  final List<String> _sampleImages = [
    'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=500&auto=format&fit=crop&q=60',
    'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=500&auto=format&fit=crop&q=60',
    'https://images.unsplash.com/photo-1581094288338-2314dddb7eed?w=500&auto=format&fit=crop&q=60',
  ];
  List<String> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _progressValue = (widget.project['progress'] ?? 0).toDouble();
    final projStatus = widget.project['status'] ?? 'Assigned';
    if (projStatus == 'Completed') {
      _statusValue = 'Near Completion';
    } else if (projStatus == 'Assigned') {
      _statusValue = 'Work Started';
    } else {
      _statusValue = 'In Progress';
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProgress() async {
    if (!_formKey.currentState!.validate()) return;

    // Determine status string for project
    String finalStatus = 'In Progress';
    if (_progressValue >= 100) {
      finalStatus = 'Inspection Pending';
    } else if (_progressValue == 0) {
      finalStatus = 'Assigned';
    }

    if (mounted) setState(() => _isSaving = true);
    try {
      await ContractorRepository().updateComplaintStatus(
        widget.project['id'].toString(),
        finalStatus,
      );

      widget.onUpdate(_progressValue.toInt(), finalStatus);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project progress updated successfully!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update progress: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
          'Update Progress',
          style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.project['title'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
              ),
              const SizedBox(height: 6),
              Text('ID: ${widget.project['id']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 28),

              // Progress Percentage Slider
              const Text('Progress Percentage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Current Progress', style: TextStyle(color: Colors.grey, fontSize: 13)),
                        Text('${_progressValue.toInt()}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Slider(
                      value: _progressValue,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      activeColor: AppTheme.primaryColor,
                      inactiveColor: Colors.grey.shade200,
                      label: '${_progressValue.toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          _progressValue = value;
                          if (_progressValue >= 90) {
                            _statusValue = 'Near Completion';
                          } else if (_progressValue <= 10) {
                            _statusValue = 'Work Started';
                          } else {
                            _statusValue = 'In Progress';
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Work Status Radio Buttons
              const Text('Work Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildStatusRadio('Work Started'),
                    const Divider(height: 1),
                    _buildStatusRadio('In Progress'),
                    const Divider(height: 1),
                    _buildStatusRadio('Near Completion'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Work Description Text Area
              const Text('Work Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                style: const TextStyle(fontSize: 14, color: Colors.black),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter work description' : null,
                decoration: InputDecoration(
                  hintText: 'Enter base layer compilation, asphalt repaving status, material details etc...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFB),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
              const SizedBox(height: 24),

              // Add Photos
              const Text('Add Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _sampleImages.length) {
                      return GestureDetector(
                        onTap: () {
                          // Pick next available sample image
                          final nextIdx = _selectedImages.length % _sampleImages.length;
                          setState(() {
                            _selectedImages.add(_sampleImages[nextIdx]);
                          });
                        },
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
                        ),
                      );
                    }

                    final img = _sampleImages[index];
                    final isSelected = _selectedImages.contains(img);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedImages.remove(img);
                          } else {
                            _selectedImages.add(img);
                          }
                        });
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(13),
                          child: Image.network(img, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProgress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Update Progress', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusRadio(String value) {
    return RadioListTile<String>(
      title: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      value: value,
      groupValue: _statusValue,
      activeColor: AppTheme.primaryColor,
      onChanged: (newValue) {
        if (newValue != null) {
          setState(() {
            _statusValue = newValue;
            if (_statusValue == 'Work Started') {
              _progressValue = 15;
            } else if (_statusValue == 'In Progress') {
              _progressValue = 55;
            } else if (_statusValue == 'Near Completion') {
              _progressValue = 90;
            }
          });
        }
      },
    );
  }
}
