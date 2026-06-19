import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import '../../data/contractor_repository.dart';
import 'contractor_project_details_screen.dart';
import 'contractor_jobs_screen.dart';
import 'contractor_update_progress_screen.dart';
import 'contractor_work_completion_screen.dart';
import 'contractor_payments_screen.dart';

class ContractorDashboardScreen extends StatefulWidget {
  const ContractorDashboardScreen({super.key});

  @override
  State<ContractorDashboardScreen> createState() => _ContractorDashboardScreenState();
}

class _ContractorDashboardScreenState extends State<ContractorDashboardScreen> {
  String _userName = 'Contractor';
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = false;
  final _contractorRepo = ContractorRepository();

  List<Map<String, dynamic>> get _displayProjects {
    try {
      if (_projects == null || _projects.isEmpty) {
        return _mockProjects;
      }
      return _projects;
    } catch (_) {
      return _mockProjects;
    }
  }

  final List<Map<String, dynamic>> _mockProjects = const [
    {
      'id': '#CMT-2025-001',
      'title': 'MG Road Repair',
      'roadName': 'MG Road',
      'location': 'Zone 2, Ward 15',
      'assignedDate': '10 May 2025',
      'dueDate': '20 May 2025',
      'priority': 'High',
      'status': 'In Progress',
      'progress': 65,
      'description': 'Repair damaged surface, potholes and improve road condition.',
      'officerName': 'Mr. Rajesh Sharma',
      'officerContact': '9977886655',
      'latitude': 22.3039,
      'longitude': 70.8022,
    },
    {
      'id': '#CMT-2025-002',
      'title': 'Highway Crack Repair',
      'roadName': 'Highway 8A',
      'location': 'Zone 3, Ward 22',
      'assignedDate': '12 May 2025',
      'dueDate': '25 May 2025',
      'priority': 'Medium',
      'status': 'Inspection Pending',
      'progress': 100,
      'description': 'Filling structural cracks and sealing joints across the expressway stretch.',
      'officerName': 'Mrs. Priya Patel',
      'officerContact': '9876543210',
      'latitude': 22.3100,
      'longitude': 70.8100,
    },
    {
      'id': '#CMT-2025-003',
      'title': 'Drainage Construction',
      'roadName': 'Market Link Road',
      'location': 'Zone 1, Ward 08',
      'assignedDate': '08 May 2025',
      'dueDate': '30 May 2025',
      'priority': 'Low',
      'status': 'Assigned',
      'progress': 0,
      'description': 'Build concrete side drains and link them to the main storm sewer network.',
      'officerName': 'Mr. Amit Verma',
      'officerContact': '9090909090',
      'latitude': 22.2900,
      'longitude': 70.7900,
    },
    {
      'id': '#CMT-2025-004',
      'title': 'Street Light Installation',
      'roadName': 'Ring Road Bypass',
      'location': 'Zone 4, Ward 12',
      'assignedDate': '15 May 2025',
      'dueDate': '02 Jun 2025',
      'priority': 'Medium',
      'status': 'Assigned',
      'progress': 0,
      'description': 'Install energy-efficient LED streetlights and utility poles along the bypass.',
      'officerName': 'Mr. Amit Verma',
      'officerContact': '9090909090',
      'latitude': 22.3200,
      'longitude': 70.8200,
    }
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _fetchDashboardData();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Contractor';
      });
    }
  }

  Future<void> _fetchDashboardData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final repoProjects = await _contractorRepo.getMyWorkOrders();
      if (mounted) {
        setState(() {
          _projects = repoProjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _projects = [];
          _isLoading = false;
        });
      }
    }
  }

  void _showProjectSelectorBottomSheet(String action) {
    final isDark = false;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
                  Text(
                    'Select Project to $action',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.secondaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _displayProjects.length,
                itemBuilder: (context, index) {
                  final project = _displayProjects[index];
                  return Card(
                    color: isDark ? const Color(0xFF2E2E2E) : Colors.white,
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                    ),
                    child: ListTile(
                      title: Text(
                        project['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark ? Colors.white : AppTheme.secondaryColor,
                        ),
                      ),
                      subtitle: Text(
                        'ID: ${project['id']}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                      onTap: () {
                        Navigator.pop(context);
                        if (action == 'Update Progress') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContractorUpdateProgressScreen(
                                project: project,
                                onUpdate: (progress, status) {
                                  _fetchDashboardData();
                                },
                              ),
                            ),
                          ).then((_) => _fetchDashboardData());
                        } else if (action == 'Submit Work') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContractorWorkCompletionScreen(
                                project: project,
                                onComplete: () {
                                  _fetchDashboardData();
                                },
                              ),
                            ),
                          ).then((_) => _fetchDashboardData());
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = false;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF3F7F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top Card
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0F9D58), Color(0xFF38A86B)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: const Icon(Icons.engineering_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Contractor!',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _userName,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        padding: const EdgeInsets.all(10),
                        child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // KPI stats row inside top card
                  Row(
                    children: [
                      Expanded(
                        child: _buildHeaderStat(
                          '${_displayProjects.where((p) => p['status'] == 'In Progress' || p['status'] == 'Assigned').length}',
                          'Active Projects',
                          Colors.white,
                        ),
                      ),
                      Expanded(
                        child: _buildHeaderStat(
                          '${_displayProjects.where((p) => p['status'] == 'Completed').length}',
                          'Completed',
                          Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Expanded(
                        child: _buildHeaderStat(
                          '${_displayProjects.where((p) => p['status'] == 'Inspection Pending').length}',
                          'Pending Insp.',
                          Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Expanded(
                        child: _buildHeaderStat(
                          '₹2.45L',
                          'Pending Pay',
                          Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _fetchDashboardData,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickActionBtn(Icons.assignment, 'My Projects', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractorJobsScreen()));
                      }),
                      _buildQuickActionBtn(Icons.trending_up, 'Upload Progress', () {
                        _showProjectSelectorBottomSheet('Update Progress');
                      }),
                      _buildQuickActionBtn(Icons.done_all, 'Submit Work', () {
                        _showProjectSelectorBottomSheet('Submit Work');
                      }),
                      _buildQuickActionBtn(Icons.currency_rupee, 'Payments', () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractorPaymentsScreen()));
                      }),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Recent Projects
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Projects',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.secondaryColor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ContractorJobsScreen()));
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            color: isDark ? AppTheme.primaryColor : AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Project cards list
                  ..._displayProjects.take(3).map((project) {
                    final statusColor = project['status'] == 'Completed'
                        ? (isDark ? Colors.green.shade400 : const Color(0xFF2E7D32))
                        : project['status'] == 'In Progress'
                            ? (isDark ? Colors.orange.shade400 : const Color(0xFFF57C00))
                            : (isDark ? Colors.blue.shade400 : const Color(0xFF1976D2));
                    final statusBg = project['status'] == 'Completed'
                        ? (isDark ? Colors.green.shade900.withOpacity(0.3) : const Color(0xFFE8F5E9))
                        : project['status'] == 'In Progress'
                            ? (isDark ? Colors.orange.shade900.withOpacity(0.3) : const Color(0xFFFFF4E5))
                            : (isDark ? Colors.blue.shade900.withOpacity(0.3) : const Color(0xFFE3F2FD));

                    return Card(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent),
                      ),
                      elevation: isDark ? 0 : 2,
                      shadowColor: Colors.black.withOpacity(0.04),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContractorProjectDetailsScreen(project: project),
                            ),
                          ).then((_) => _fetchDashboardData());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      project['title']!,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : AppTheme.secondaryColor,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      project['status']!,
                                      style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                project['location']!,
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Due: ${project['dueDate']}',
                                    style: TextStyle(
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (project['status'] != 'Assigned')
                                    Text(
                                      '${project['progress']}% done',
                                      style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 11),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildQuickActionBtn(IconData icon, String label, VoidCallback onTap) {
    final isDark = false;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white.withOpacity(0.9) : AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
