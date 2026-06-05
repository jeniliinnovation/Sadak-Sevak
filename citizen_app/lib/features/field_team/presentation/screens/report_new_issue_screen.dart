import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class ReportNewIssueScreen extends StatefulWidget {
  const ReportNewIssueScreen({super.key});

  @override
  State<ReportNewIssueScreen> createState() => _ReportNewIssueScreenState();
}

class _ReportNewIssueScreenState extends State<ReportNewIssueScreen> {
  String? _selectedType;
  final _descController = TextEditingController();
  final _locationController = TextEditingController(
      text: 'NH-48, Delhi – Jaipur\nNear KM 25, Rajasthan');

  static const Color _blue = Color(0xFF4A80F0);
  static const Color _darkBlue = Color(0xFF0D47A1);

  static const List<Map<String, dynamic>> _issueTypes = [
    {'label': 'Road\nDamage', 'icon': Icons.report_problem_outlined},
    {'label': 'Pothole', 'icon': Icons.radio_button_unchecked},
    {'label': 'Street\nLight', 'icon': Icons.lightbulb_outline},
    {'label': 'Water\nLogging', 'icon': Icons.water_damage_outlined},
    {'label': 'Other', 'icon': Icons.more_horiz_rounded},
  ];

  @override
  void dispose() {
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Report New Issue',
            style: TextStyle(
                color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Issue Type ─────────────────────────────────────────
            FadeInDown(
              child: _sectionCard(
                title: 'Issue Type',
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _issueTypes.map((type) {
                    final selected = _selectedType == type['label'];
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedType = type['label']),
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected
                                  ? _blue
                                  : const Color(0xFFEEF3FF),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                          color: _blue.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4))
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              type['icon'] as IconData,
                              color: selected ? Colors.white : _blue,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            (type['label'] as String)
                                .replaceAll('\n', ' '),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? _blue
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ─── Location ───────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 80),
              child: _sectionCard(
                title: 'Location',
                trailing: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.my_location, size: 14, color: _blue),
                  label: const Text('Use Current Location',
                      style: TextStyle(fontSize: 12, color: _blue)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _locationController,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF1A1A2E)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: _blue, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {},
                      child: Text('Change',
                          style: const TextStyle(
                              color: _blue,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ─── Description ────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 130),
              child: _sectionCard(
                title: 'Description',
                child: TextField(
                  controller: _descController,
                  maxLines: 4,
                  maxLength: 200,
                  decoration: InputDecoration(
                    hintText: 'Brief description of the issue...',
                    hintStyle:
                        TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: _blue, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ─── Add Photos ─────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 170),
              child: _sectionCard(
                title: 'Add Photos',
                child: Row(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid),
                          ),
                          child: Icon(Icons.add_a_photo_outlined,
                              color: Colors.grey.shade400, size: 26),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            FadeInUp(
              delay: const Duration(milliseconds: 210),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report submitted successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Submit Report',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(
      {required String title,
      required Widget child,
      Widget? trailing}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _darkBlue)),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
