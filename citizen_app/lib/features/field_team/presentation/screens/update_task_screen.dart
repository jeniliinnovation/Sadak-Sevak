import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class UpdateTaskScreen extends StatefulWidget {
  const UpdateTaskScreen({super.key});

  @override
  State<UpdateTaskScreen> createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  String _selectedStatus = 'In Progress';
  final _remarksController = TextEditingController();

  static const Color _blue = Color(0xFF4A80F0);
  static const Color _darkBlue = Color(0xFF0D47A1);

  static const List<_StatusOption> _statuses = [
    _StatusOption('Pending', Icons.circle_outlined, Colors.orange),
    _StatusOption('In Progress', Icons.autorenew_rounded, Color(0xFF4A80F0)),
    _StatusOption('Completed', Icons.check_circle_outline, Colors.green),
    _StatusOption('On Hold', Icons.pause_circle_outline, Colors.grey),
  ];

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Update Status',
            style: TextStyle(
                color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Status
            FadeInDown(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Current Status',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF3FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.autorenew_rounded,
                            color: _blue, size: 18),
                        const SizedBox(width: 8),
                        const Text('In Progress',
                            style: TextStyle(
                                color: _blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Update To
            FadeInUp(
              delay: const Duration(milliseconds: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Update To',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  ...List.generate(_statuses.length, (i) {
                    final s = _statuses[i];
                    final selected = _selectedStatus == s.label;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedStatus = s.label),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? s.color.withOpacity(0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                selected ? s.color : Colors.grey.shade200,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color:
                                  selected ? s.color : Colors.grey.shade400,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Icon(s.icon, color: s.color, size: 18),
                            const SizedBox(width: 10),
                            Text(s.label,
                                style: TextStyle(
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: selected
                                        ? s.color
                                        : Colors.grey.shade700,
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Work Details
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Work Details',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _darkBlue)),
                    const SizedBox(height: 12),
                    _detailRow(Icons.play_circle_outline, 'Work Started',
                        'May 12, 2025 11:00 AM'),
                    const SizedBox(height: 10),
                    _detailRow(Icons.flag_outlined,
                        'Estimated Completion', 'May 12, 2025 03:00 PM'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Remarks
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Remarks',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _remarksController,
                    maxLines: 3,
                    maxLength: 200,
                    decoration: InputDecoration(
                      hintText:
                          'Work in progress. Material arrived at site.',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      filled: true,
                      fillColor: Colors.grey.shade50,
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
                        borderSide:
                            const BorderSide(color: _blue, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            FadeInUp(
              delay: const Duration(milliseconds: 240),
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task status updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Save Update',
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

  Widget _detailRow(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text(label,
              style:
                  TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF1A1A2E))),
        ],
      );
}

class _StatusOption {
  final String label;
  final IconData icon;
  final Color color;
  const _StatusOption(this.label, this.icon, this.color);
}
