import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class TaskHistoryScreen extends StatefulWidget {
  const TaskHistoryScreen({super.key});

  @override
  State<TaskHistoryScreen> createState() => _TaskHistoryScreenState();
}

class _TaskHistoryScreenState extends State<TaskHistoryScreen> {
  String _selectedTab = 'All';
  static const Color _blue = Color(0xFF4A80F0);
  static const Color _darkBlue = Color(0xFF0D47A1);

  static const List<Map<String, dynamic>> _history = [
    {
      'title': 'Road Damage',
      'location': 'NH-48, Delhi – Jaipur',
      'date': 'May 12, 2025',
      'status': 'Completed',
      'icon': Icons.report_problem_outlined,
    },
    {
      'title': 'Pothole Report',
      'location': 'SH-25, Agra – Mathura',
      'date': 'May 12, 2025 11:40 AM',
      'status': 'Completed',
      'icon': Icons.radio_button_unchecked,
    },
    {
      'title': 'Street Light Out',
      'location': 'City Road, Sector 12',
      'date': 'May 11, 2025 04:10 PM',
      'status': 'Completed',
      'icon': Icons.lightbulb_outline,
    },
    {
      'title': 'Water Logging',
      'location': 'MG Road, Bangalore',
      'date': 'May 10, 2025 10:15 AM',
      'status': 'Cancelled',
      'icon': Icons.water_damage_outlined,
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_selectedTab == 'All') return _history;
    return _history
        .where((t) => t['status'] == _selectedTab)
        .toList();
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
        title: const Text('Task History',
            style: TextStyle(
                color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All', 'Completed', 'Cancelled'].map((tab) {
                  final selected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTab = tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 9),
                        decoration: BoxDecoration(
                          color: selected ? _blue : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: selected
                                  ? _blue
                                  : Colors.grey.shade200),
                        ),
                        child: Text(tab,
                            style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final t = _filtered[i];
                return FadeInUp(
                  delay: Duration(milliseconds: i * 60),
                  child: _historyCard(t),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> task) {
    final isCompleted = task['status'] == 'Completed';
    final statusColor = isCompleted ? Colors.green : Colors.red;
    final statusBg = isCompleted
        ? Colors.green.shade50
        : Colors.red.shade50;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(12)),
            child:
                Icon(task['icon'] as IconData, color: _blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E))),
                Text(task['location'],
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12)),
                Text(task['date'],
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(8)),
            child: Text(task['status'],
                style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
