import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'task_details_screen.dart';
import 'report_new_issue_screen.dart';
import 'sync_data_screen.dart';
import 'my_tasks_screen.dart';
import '../../../complaints/domain/complaint_model.dart';
import '../../../government/data/government_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FieldTeamDashboard extends StatefulWidget {
  const FieldTeamDashboard({super.key});

  @override
  State<FieldTeamDashboard> createState() => _FieldTeamDashboardState();
}

class _FieldTeamDashboardState extends State<FieldTeamDashboard> {
  final _repository = GovernmentRepository();
  List<Complaint> _complaints = [];
  bool _isLoading = true;
  String _userName = 'Priya Mehta';
  String _userRole = 'Field Team Member';

  static const Color _blue = Color(0xFF4A80F0);
  static const Color _darkBlue = Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDashboardData();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Priya Mehta';
      _userRole = prefs.getString('user_role') ?? 'Field Team Member';
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      final list = await _repository.getComplaints();
      if (mounted) {
        setState(() {
          _complaints = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int total = _complaints.length;
    int pending = _complaints.where((c) {
      final s = c.status.toLowerCase();
      return s == 'submitted' || s == 'pending' || s == 'under_review';
    }).length;
    int inProgress = _complaints.where((c) {
      final s = c.status.toLowerCase();
      return s == 'repair_started' || s == 'team_assigned';
    }).length;
    int completed = _complaints.where((c) {
      final s = c.status.toLowerCase();
      return s == 'repair_completed' || s == 'verified_closed';
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          color: _blue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header (Citizen-style Premium Design in Blue) ───────────
                FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 30),
                    decoration: const BoxDecoration(
                      color: _blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white24,
                              child: Icon(Icons.engineering_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, $_userName 👋',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  _userRole,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ─── Today's Tasks Banner ───────────────────────
                      FadeInUp(
                        delay: const Duration(milliseconds: 80),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Today's Tasks Summary",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: _darkBlue,
                                ),
                              ),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.refresh,
                                  color: _blue,
                                  size: 18,
                                ),
                                onPressed: () {
                                  setState(() => _isLoading = true);
                                  _loadDashboardData();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ─── Task Count Card ────────────────────────────
                      FadeInUp(
                        delay: const Duration(milliseconds: 130),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 80,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: _blue,
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    Text(
                                      '$total',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: _darkBlue,
                                      ),
                                    ),
                                    Divider(
                                      color: Colors.grey.shade100,
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _miniStat('$pending', 'Pending'),
                                        Container(
                                          width: 1,
                                          height: 28,
                                          color: Colors.grey.shade200,
                                        ),
                                        _miniStat('$inProgress', 'In Progress'),
                                        Container(
                                          width: 1,
                                          height: 28,
                                          color: Colors.grey.shade200,
                                        ),
                                        _miniStat('$completed', 'Completed'),
                                      ],
                                    ),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 18),
                      // ─── Quick Actions ──────────────────────────────
                      FadeInUp(
                        delay: const Duration(milliseconds: 210),
                        child: _card(
                          title: 'Quick Actions',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _quickAction(
                                Icons.add_circle_outline,
                                'Report',
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ReportNewIssueScreen(),
                                  ),
                                ),
                              ),
                              _quickAction(
                                Icons.assignment_outlined,
                                'My Tasks',
                                () {
                                  // Navigate to Tasks tab (index 2 in main layout) or page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MyTasksScreen(),
                                    ),
                                  );
                                },
                              ),
                              _quickAction(
                                Icons.person_outline,
                                'My Profile',
                                () {},
                              ),
                              _quickAction(
                                Icons.sync_rounded,
                                'Sync Data',
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SyncDataScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ─── Assignments ────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Assignments',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _darkBlue,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyTasksScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'View All',
                              style: TextStyle(color: _blue),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      _isLoading
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: CircularProgressIndicator(color: _blue),
                              ),
                            )
                          : _complaints.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Text(
                                  'No assignments found.',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ),
                            )
                          : Column(
                              children: List.generate(
                                _complaints.length > 5 ? 5 : _complaints.length,
                                (i) {
                                  final t = _complaints[i];
                                  return FadeInUp(
                                    key: ValueKey(t.id),
                                    delay: Duration(milliseconds: 250 + i * 60),
                                    child: _taskCard(context, t),
                                  );
                                },
                              ),
                            ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniStat(String v, String label) => Column(
    children: [
      Text(
        v,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _darkBlue,
        ),
      ),
      Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
    ],
  );

  Widget _statBlock(String v, String label) => Column(
    children: [
      Text(
        v,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: _darkBlue,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
      ),
    ],
  );

  Widget _card({required String title, required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: _darkBlue,
          ),
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );

  Widget _quickAction(IconData icon, String label, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF3FF),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: _blue, size: 22),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  Widget _taskCard(BuildContext context, Complaint complaint) {
    IconData icon;
    switch (complaint.category.toLowerCase()) {
      case 'potholes':
      case 'pothole':
        icon = Icons.radio_button_unchecked;
        break;
      case 'street light':
      case 'lighting':
        icon = Icons.lightbulb_outline;
        break;
      case 'drainage':
      case 'sewage':
        icon = Icons.water_damage_outlined;
        break;
      default:
        icon = Icons.report_problem_outlined;
    }

    Color priorityColor;
    switch (complaint.priority.toLowerCase()) {
      case 'critical':
      case 'high':
        priorityColor = Colors.red;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }

    String status = 'Pending';
    Color statusColor = const Color(0xFFE67E00);
    Color statusBg = const Color(0xFFFFF3E0);

    if (complaint.status == 'repair_started') {
      status = 'In Progress';
      statusColor = _blue;
      statusBg = const Color(0xFFEEF3FF);
    } else if (complaint.status == 'repair_completed' ||
        complaint.status == 'verified_closed') {
      status = 'Completed';
      statusColor = Colors.green;
      statusBg = Colors.green.shade50;
    }

    final address = complaint.location['address'] ?? 'Unknown Location';
    final teamName = complaint.assignedTeamName?.isNotEmpty == true
        ? complaint.assignedTeamName!
        : (complaint.assignedTeamId ?? 'Unassigned');
    final statusLabel = complaint.status == 'repair_started'
        ? 'In Progress'
        : complaint.status == 'repair_completed' || complaint.status == 'verified_closed'
            ? 'Completed'
            : complaint.status == 'team_assigned'
                ? 'Team Assigned'
                : 'Pending';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TaskDetailsScreen(complaint: complaint),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      complaint.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${complaint.priority} Priority',
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Team: $teamName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Status: $statusLabel',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
