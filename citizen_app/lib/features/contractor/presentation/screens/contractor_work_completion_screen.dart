import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import '../../data/contractor_repository.dart';

class ContractorWorkCompletionScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  final VoidCallback? onComplete;

  const ContractorWorkCompletionScreen({
    super.key,
    required this.project,
    this.onComplete,
  });

  @override
  State<ContractorWorkCompletionScreen> createState() => _ContractorWorkCompletionScreenState();
}

class _ContractorWorkCompletionScreenState extends State<ContractorWorkCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _summaryController = TextEditingController();
  final _materialsController = TextEditingController();
  final _durationController = TextEditingController(text: '10 May 2025 - 18 May 2025');

  String? _selectedPdfName;
  String? _selectedPdfSize;
  List<String> _completionPhotos = [];
  bool _isSubmitting = false;

  final List<String> _samplePhotos = [
    'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=500',
    'https://images.unsplash.com/photo-1581094288338-2314dddb7eed?w=500',
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=500',
  ];

  final List<Map<String, String>> _samplePdfs = [
    {'name': 'completion_report_mg_road.pdf', 'size': '1.2 MB'},
    {'name': 'final_asphalt_quality_test.pdf', 'size': '950 KB'},
  ];

  @override
  void dispose() {
    _summaryController.dispose();
    _materialsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

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
                  const Text('Select Completion PDF', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 16),
              ..._samplePdfs.map((pdf) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.red.shade50, child: const Icon(Icons.picture_as_pdf, color: Colors.red)),
                    title: Text(pdf['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(pdf['size']!, style: const TextStyle(fontSize: 12)),
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

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPdfName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload the PDF Completion Report'), backgroundColor: Colors.red),
      );
      return;
    }

    if (mounted) setState(() => _isSubmitting = true);
    try {
      await ContractorRepository().updateComplaintStatus(
        widget.project['id'].toString(),
        'Completed',
      );

      if (widget.onComplete != null) {
        widget.onComplete!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Work completion report submitted for inspection!'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
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
          'Work Completion',
          style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.project['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('ID: ${widget.project['id']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),

              _buildLabel('Completion Summary'),
              TextFormField(
                controller: _summaryController,
                maxLines: 3,
                style: const TextStyle(fontSize: 14),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter completion summary' : null,
                decoration: _buildInputDec('All repair work completed. Road surface leveled and asphalt laid successfully.'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Materials Used'),
              TextFormField(
                controller: _materialsController,
                style: const TextStyle(fontSize: 14),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please specify materials used' : null,
                decoration: _buildInputDec('Bitumen, Asphalt Mix, Concrete, Stone Chips'),
              ),
              const SizedBox(height: 16),

              _buildLabel('Work Duration'),
              TextFormField(
                controller: _durationController,
                style: const TextStyle(fontSize: 14),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please specify duration' : null,
                decoration: _buildInputDec('e.g. 10 May 2025 - 18 May 2025'),
              ),
              const SizedBox(height: 24),

              // Completion Photos
              const Text('Upload Completion Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondaryColor)),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _completionPhotos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _completionPhotos.length) {
                      return GestureDetector(
                        onTap: () {
                          final nextIdx = _completionPhotos.length % _samplePhotos.length;
                          setState(() => _completionPhotos.add(_samplePhotos[nextIdx]));
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

                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(_completionPhotos[index], fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 2,
                          right: 14,
                          child: GestureDetector(
                            onTap: () => setState(() => _completionPhotos.removeAt(index)),
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              padding: const EdgeInsets.all(3),
                              child: const Icon(Icons.close, color: Colors.white, size: 10),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Completion Report PDF
              const Text('Upload Completion Report (PDF)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondaryColor)),
              const SizedBox(height: 12),
              if (_selectedPdfName == null)
                GestureDetector(
                  onTap: _pickPdf,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf_outlined, color: Colors.grey),
                        SizedBox(width: 10),
                        Text('Choose PDF Document', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.red.shade100)),
                  color: Colors.red.shade50.withOpacity(0.3),
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                    title: Text(_selectedPdfName!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(_selectedPdfSize!, style: const TextStyle(fontSize: 12)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => setState(() {
                        _selectedPdfName = null;
                        _selectedPdfSize = null;
                      }),
                    ),
                  ),
                ),
              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Submit for Inspection', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 13)),
    );
  }

  InputDecoration _buildInputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFB),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200)),
    );
  }
}
