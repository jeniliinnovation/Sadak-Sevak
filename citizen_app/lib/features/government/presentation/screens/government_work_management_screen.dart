import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/government/domain/models/work_task_model.dart';
import 'package:sadak_sevak_citizen/features/government/presentation/screens/government_work_details_screen.dart';

class GovernmentWorkManagementScreen extends StatefulWidget {
  const GovernmentWorkManagementScreen({super.key});

  @override
  State<GovernmentWorkManagementScreen> createState() => _GovernmentWorkManagementScreenState();
}

class _GovernmentWorkManagementScreenState extends State<GovernmentWorkManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GovernmentRepository _repository = GovernmentRepository();

  bool _isLoading = true;
  List<WorkTaskModel> _works = [];
  String selectedStatus = 'All Status';
  String selectedMonth = 'All Month';
  static const List<String> monthOptions = [
    'All Month',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    _fetchWorks();
  }

  Future<void> _fetchWorks() async {
    try {
      final works = await _repository.getWorkTasks();
      setState(() {
        _works = works;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);
    const darkOrange = Color(0xFFD84315);

    List<WorkTaskModel> filteredWorks = _works.where((work) {
      final query = _searchController.text.toLowerCase();
      final matchesSearch = work.title.toLowerCase().contains(query) ||
          work.id.toLowerCase().contains(query) ||
          work.team.toLowerCase().contains(query);
      final matchesStatus = selectedStatus == 'All Status' ||
          _getWorkStatusCategory(work.status).toLowerCase() == selectedStatus.toLowerCase();
      final matchesMonth = selectedMonth == 'All Month' || work.date.startsWith(selectedMonth);
      return matchesSearch && matchesStatus && matchesMonth;
    }).toList();
    final teamProgress = _groupTeamProgress(filteredWorks);
    final totalComplaints = filteredWorks.length;
    final completedComplaints = filteredWorks.where((work) => _getWorkStatusCategory(work.status).toLowerCase() == 'complete').length;
    final inProgressComplaints = filteredWorks.where((work) => _getWorkStatusCategory(work.status).toLowerCase() == 'in progress').length;
    final pendingComplaints = filteredWorks.where((work) => _getWorkStatusCategory(work.status).toLowerCase() == 'pending').length;
    final workDonePercent = totalComplaints > 0 ? (completedComplaints / totalComplaints * 100).round() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Orange Gradient Header with Search & Filters
            FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 56, left: 20, right: 20, bottom: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryOrange, darkOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33F4511E),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1.5),
                        ),
                        child: const Icon(Icons.engineering_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Work Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${filteredWorks.length} tasks found',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$totalComplaints',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Divider(color: Colors.white.withOpacity(0.4), thickness: 1),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMiniHeaderStat('Pending', pendingComplaints.toString()),
                            _buildMiniHeaderStat('In Progress', inProgressComplaints.toString()),
                            _buildMiniHeaderStat('Completed', completedComplaints.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search work by ID or title...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: Colors.grey.shade400),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Filter Chips Row
                  Row(
                    children: [
                      Expanded(
                        child: PopupMenuButton<String>(
                          initialValue: selectedStatus,
                          onSelected: (String item) {
                            setState(() => selectedStatus = item);
                          },
                          offset: const Offset(0, 48),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(value: 'All Status', child: Text('All Status', style: TextStyle(color: Colors.black87))),
                            const PopupMenuItem<String>(value: 'Pending', child: Text('Pending', style: TextStyle(color: Colors.black87))),
                            const PopupMenuItem<String>(value: 'In Progress', child: Text('In Progress', style: TextStyle(color: Colors.black87))),
                            const PopupMenuItem<String>(value: 'Complete', child: Text('Complete', style: TextStyle(color: Colors.black87))),
                            const PopupMenuItem<String>(value: 'On Hold', child: Text('On Hold', style: TextStyle(color: Colors.black87))),
                          ],
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedStatus,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white70),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PopupMenuButton<String>(
                          initialValue: selectedMonth,
                          onSelected: (String item) {
                            setState(() => selectedMonth = item);
                          },
                          offset: const Offset(0, 48),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          itemBuilder: (BuildContext context) => monthOptions.map((month) {
                            return PopupMenuItem<String>(
                              value: month,
                              child: Text(month, style: const TextStyle(color: Colors.black87)),
                            );
                          }).toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    selectedMonth,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.white70),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: primaryOrange))
              : _buildTeamProgressList(teamProgress),
          ),
        ],
      ),
    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: primaryOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Work',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }

  Widget _buildTeamProgressList(List<_TeamProgress> list) {

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.engineering_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No team progress found',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final team = list[index];

        return FadeInUp(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: 50 * index),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF4511E),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        team.teamName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${team.taskCount} tasks • ${team.completedCount} completed',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTeamStatTile(
                      '${team.taskCount}',
                      'Total',
                      const Color(0xFFFFF3E0),
                      const Color(0xFFF4511E),
                    ),
                    _buildTeamStatTile(
                      '${team.completedCount}',
                      'Completed',
                      const Color(0xFFE8F5E9),
                      const Color(0xFF43A047),
                    ),
                    _buildTeamStatTile(
                      '${team.taskCount - team.completedCount}',
                      'Pending',
                      const Color(0xFFE3F2FD),
                      const Color(0xFF1E88E5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamStatTile(String value, String label, Color bgColor, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF546E7A),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_TeamProgress> _groupTeamProgress(List<WorkTaskModel> works) {
    final Map<String, _TeamProgress> map = {};
    for (final work in works) {
      final teamName = work.team.isNotEmpty ? work.team : 'Unassigned';
      final entry = map.putIfAbsent(teamName, () => _TeamProgress(teamName: teamName));
      entry.taskCount += 1;
      entry.totalProgress += work.progress;
      if (work.status.toLowerCase() == 'completed') {
        entry.completedCount += 1;
      }
    }
    return map.values.map((entry) {
      entry.averageProgress = entry.taskCount > 0 ? (entry.totalProgress / entry.taskCount) : 0.0;
      return entry;
    }).toList()
      ..sort((a, b) => b.averageProgress.compareTo(a.averageProgress));
  }

  Widget _buildStatusBadge(String status) {
    final displayStatus = _getWorkStatusCategory(status);
    Color color;
    Color bgColor;
    switch (displayStatus.toLowerCase()) {
      case 'complete':
        color = const Color(0xFF43A047);
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 'in progress':
        color = const Color(0xFF1E88E5);
        bgColor = const Color(0xFFE3F2FD);
        break;
      case 'on hold':
        color = const Color(0xFFFB8C00);
        bgColor = const Color(0xFFFFFDE7);
        break;
      case 'pending':
        color = const Color(0xFFF4511E);
        bgColor = const Color(0xFFFFF3E0);
        break;
      default:
        color = const Color(0xFF78909C);
        bgColor = const Color(0xFFECEFF1);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getWorkStatusCategory(String status) {
    final lower = status.toLowerCase();
    if (lower == 'repair_completed' || lower == 'verified_closed' || lower == 'completed') {
      return 'Complete';
    }
    if (lower == 'team_assigned' || lower == 'repair_started' || lower == 'repair_in_progress' || lower == 'in progress') {
      return 'In Progress';
    }
    if (lower == 'submitted' || lower == 'pending' || lower == 'under_review' || lower == 'pending action' || lower == 'pending action') {
      return 'Pending';
    }
    return status.replaceAll('_', ' ').toLowerCase() == 'on hold' ? 'On Hold' : 'Pending';
  }
}

class _TeamProgress {
  final String teamName;
  int taskCount;
  int completedCount;
  double totalProgress;
  double averageProgress;

  _TeamProgress({
    required this.teamName,
    this.taskCount = 0,
    this.completedCount = 0,
    this.totalProgress = 0.0,
    this.averageProgress = 0.0,
  });
}
