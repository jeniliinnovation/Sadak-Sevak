import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';

class ContractorInspectionStatusScreen extends StatelessWidget {
  final Map<String, dynamic> project;

  const ContractorInspectionStatusScreen({
    super.key,
    required this.project,
  });

  final List<Map<String, dynamic>> _timelineStages = const [
    {'title': 'Reported', 'date': '10 May 2025', 'isDone': true},
    {'title': 'Assigned', 'date': '10 May 2025', 'isDone': true},
    {'title': 'Work Started', 'date': '12 May 2025', 'isDone': true},
    {'title': 'Inspection Scheduled', 'date': '15 May 2025', 'isDone': true},
    {'title': 'Under Inspection', 'date': '16 May 2025', 'isCurrent': true, 'isDone': false},
    {'title': 'Approved', 'date': 'Pending', 'isDone': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Inspection Status', style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('ID: ${project['id']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const SizedBox(height: 24),

            // Timeline Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: List.generate(_timelineStages.length, (index) {
                  final stage = _timelineStages[index];
                  final isLast = index == _timelineStages.length - 1;
                  final isDone = stage['isDone'] ?? false;
                  final isCurrent = stage['isCurrent'] ?? false;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Line & Dot
                      Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isDone
                                  ? AppTheme.primaryColor
                                  : isCurrent
                                      ? AppTheme.primaryColor.withOpacity(0.15)
                                      : Colors.grey.shade200,
                              shape: BoxShape.circle,
                              border: isCurrent ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
                            ),
                            child: Icon(
                              isDone ? Icons.check : Icons.circle,
                              color: isDone
                                  ? Colors.white
                                  : isCurrent
                                      ? AppTheme.primaryColor
                                      : Colors.grey.shade400,
                              size: isDone ? 14 : 8,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 50,
                              color: isDone ? AppTheme.primaryColor : Colors.grey.shade200,
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Text info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stage['title']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: isDone || isCurrent ? AppTheme.secondaryColor : Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stage['date']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDone || isCurrent ? Colors.grey.shade600 : Colors.grey.shade300,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 28),

            // Inspector Details Section
            const Text('Inspector Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.secondaryColor)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildInspectorRow(Icons.person_outline, 'Inspector Name', project['officerName'] ?? 'Mr. Rajesh Sharma'),
                  const Divider(height: 24),
                  _buildInspectorRow(Icons.phone_outlined, 'Contact Number', project['officerContact'] ?? '9977886655'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectorRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondaryColor)),
            ],
          ),
        ),
      ],
    );
  }
}
