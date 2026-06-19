import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';

class ContractorUploadPhotosScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const ContractorUploadPhotosScreen({
    super.key,
    required this.project,
  });

  @override
  State<ContractorUploadPhotosScreen> createState() => _ContractorUploadPhotosScreenState();
}

class _ContractorUploadPhotosScreenState extends State<ContractorUploadPhotosScreen> {
  final Map<String, List<String>> _uploadedPhotos = {
    'Before Work': [
      'https://images.unsplash.com/photo-1541888946425-d81bb19240f5?w=300',
    ],
    'During Work': [],
    'After Work': [],
  };

  final List<String> _samplePool = [
    'https://images.unsplash.com/photo-1590069261209-f8e9b8642343?w=500',
    'https://images.unsplash.com/photo-1581094288338-2314dddb7eed?w=500',
    'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=500',
    'https://images.unsplash.com/photo-1590674899484-d5640e854abe?w=500',
  ];

  void _addPhoto(String category) {
    // Simulate picking an image from the pool
    final nextIndex = _uploadedPhotos[category]!.length % _samplePool.length;
    setState(() {
      _uploadedPhotos[category]!.add(_samplePool[nextIndex]);
    });
  }

  void _removePhoto(String category, int index) {
    setState(() {
      _uploadedPhotos[category]!.removeAt(index);
    });
  }

  void _submitPhotos() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Site verification photos submitted successfully!'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
    Navigator.pop(context);
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
          'Upload Site Photos',
          style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.project['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('ID: ${widget.project['id']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),
            const Text(
              'Upload site photographs to verify the work stage details.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),

            _buildCategorySection('Before Work', 'Upload road damage photographs prior to start:'),
            const SizedBox(height: 24),
            _buildCategorySection('During Work', 'Upload progress photographs during layout reconstruction:'),
            const SizedBox(height: 24),
            _buildCategorySection('After Work', 'Upload final completed road repaving photographs:'),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _submitPhotos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Submit All Photos', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category, String description) {
    final list = _uploadedPhotos[category] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.secondaryColor)),
            Text('${list.length} uploaded', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 6),
        Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: list.length + 1,
            itemBuilder: (context, index) {
              if (index == list.length) {
                return GestureDetector(
                  onTap: () => _addPhoto(category),
                  child: Container(
                    width: 90,
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

              final url = list[index];
              return Stack(
                children: [
                  Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(url, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => _removePhoto(category, index),
                      child: Container(
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
