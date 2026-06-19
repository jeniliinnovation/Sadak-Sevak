import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:sadak_sevak_citizen/features/complaints/domain/complaint_model.dart';
import 'package:sadak_sevak_citizen/features/complaints/data/complaint_repository.dart';
import 'package:sadak_sevak_citizen/features/complaints/presentation/screens/complaint_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/contractor_repository.dart';
import 'contractor_project_details_screen.dart';
import 'package:intl/intl.dart';

class ContractorJobsScreen extends StatefulWidget {
  const ContractorJobsScreen({super.key});

  @override
  State<ContractorJobsScreen> createState() => _ContractorJobsScreenState();
}

class _ContractorJobsScreenState extends State<ContractorJobsScreen> {
  int _activeTabIndex = 0; // 0 for Work Orders, 1 for Available Bids
  final _complaintRepo = ComplaintRepository();
  final _contractorRepo = ContractorRepository();
  List<Complaint> _availableComplaints = [];
  bool _isLoadingComplaints = false;
  List<Map<String, dynamic>> _projects = [];
  bool _isLoadingProjects = false;
  List<String> _submittedOfferIds = [];
  bool _showMyBidsOnly = false;

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
    _fetchComplaints();
    _fetchProjects();
    _loadSubmittedOffers();
  }

  Future<void> _loadSubmittedOffers() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _submittedOfferIds = prefs.getStringList('contractor_submitted_offers') ?? [];
      });
    }

    try {
      final bids = await _contractorRepo.getMyBids();
      if (bids.isNotEmpty) {
        final List<String> newOfferIds = [];
        for (var bid in bids) {
          final String? complaintId = bid['complaintId']?.toString();
          if (complaintId != null) {
            newOfferIds.add(complaintId);
            
            // Cache cost, duration, message in SharedPreferences
            final cost = bid['cost']?.toString() ?? '';
            final duration = bid['duration']?.toString() ?? '';
            final message = bid['message']?.toString() ?? '';
            
            await prefs.setString('offer_cost_$complaintId', cost);
            await prefs.setString('offer_duration_$complaintId', duration);
            await prefs.setString('offer_message_$complaintId', message);
          }
        }
        
        await prefs.setStringList('contractor_submitted_offers', newOfferIds);
        if (mounted) {
          setState(() {
            _submittedOfferIds = newOfferIds;
          });
        }
      }
    } catch (e) {
      debugPrint('Error syncing bids from database in jobs screen: $e');
    }
  }

  Future<void> _fetchProjects() async {
    if (mounted) setState(() => _isLoadingProjects = true);
    try {
      final list = await _contractorRepo.getMyWorkOrders();
      if (mounted) {
        setState(() {
          _projects = list;
          _isLoadingProjects = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProjects = false);
      }
    }
  }

  Future<void> _fetchComplaints() async {
    setState(() => _isLoadingComplaints = true);
    try {
      final list = await _complaintRepo.getAllComplaints();
      if (mounted) {
        setState(() {
          _availableComplaints = list.where((c) => c.status != 'verified_closed').toList();
          _isLoadingComplaints = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingComplaints = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = false;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeTabIndex == 0 ? 'My Work Orders' : 'Available Bids',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: isDark ? Colors.white : AppTheme.secondaryColor,
                    ),
                  ),
                  if (_activeTabIndex == 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${_displayProjects.length} Active',
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // Segmented Toggle
              Row(
                children: [
                  Expanded(child: _buildTabChip('Work Orders', 0)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTabChip('Available Bids', 1)),
                ],
              ),
              const SizedBox(height: 20),

              if (_activeTabIndex == 1) ...[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showMyBidsOnly = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: !_showMyBidsOnly ? (isDark ? AppTheme.primaryColor : Colors.white) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: !_showMyBidsOnly && !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                            ),
                            child: Text('Available', style: TextStyle(fontWeight: !_showMyBidsOnly ? FontWeight.bold : FontWeight.normal, color: !_showMyBidsOnly ? (isDark ? Colors.white : AppTheme.primaryColor) : Colors.grey.shade600, fontSize: 13)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _showMyBidsOnly = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _showMyBidsOnly ? (isDark ? AppTheme.primaryColor : Colors.white) : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _showMyBidsOnly && !isDark ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
                            ),
                            child: Text('My Bids', style: TextStyle(fontWeight: _showMyBidsOnly ? FontWeight.bold : FontWeight.normal, color: _showMyBidsOnly ? (isDark ? Colors.white : AppTheme.primaryColor) : Colors.grey.shade600, fontSize: 13)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Active List View
              Expanded(
                child: _activeTabIndex == 0 ? _buildWorkOrdersList() : _buildAvailableBidsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, int index) {
    final isDark = false;
    final isSelected = _activeTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _activeTabIndex = index);
        if (index == 1) {
          _fetchComplaints();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildWorkOrdersList() {
    final isDark = false;
    if (_isLoadingProjects) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _fetchProjects,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _displayProjects.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final project = _displayProjects[index];
          final statusColor = project['status'] == 'Completed'
              ? (isDark ? Colors.green.shade400 : const Color(0xFF2E7D32))
              : project['status'] == 'In Progress'
                  ? (isDark ? Colors.orange.shade400 : const Color(0xFFF57C00))
                  : (isDark ? Colors.blue.shade400 : const Color(0xFF1976D2));
          final statusBgColor = project['status'] == 'Completed'
              ? (isDark ? Colors.green.shade900.withOpacity(0.3) : const Color(0xFFE8F5E9))
              : project['status'] == 'In Progress'
                  ? (isDark ? Colors.orange.shade900.withOpacity(0.3) : const Color(0xFFFFF4E5))
                  : (isDark ? Colors.blue.shade900.withOpacity(0.3) : const Color(0xFFE3F2FD));

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContractorProjectDetailsScreen(project: project),
                    ),
                  ).then((_) => _fetchProjects());
                },
              child: Padding(
                padding: const EdgeInsets.all(18),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.secondaryColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            project['status']!,
                            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      project['location']!,
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: isDark ? Colors.grey.shade400 : Colors.grey, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Due: ${project['dueDate']}',
                              style: TextStyle(
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (project['status'] != 'Assigned')
                          Row(
                            children: [
                              const Icon(Icons.trending_up, color: AppTheme.primaryColor, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${project['progress']}%',
                                style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

  Widget _buildAvailableBidsList() {
    final isDark = false;
    if (_isLoadingComplaints) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }

    final filteredComplaints = _availableComplaints.where((c) {
      final isBidded = _submittedOfferIds.contains(c.id);
      return _showMyBidsOnly ? isBidded : !isBidded;
    }).toList();

    if (filteredComplaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300, size: 60),
            const SizedBox(height: 12),
            Text(
              _showMyBidsOnly ? 'You have not bidded on any complaints yet.' : 'No new complaints open for bidding.',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchComplaints,
      color: AppTheme.primaryColor,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: filteredComplaints.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final complaint = filteredComplaints[index];
          final priorityColor = complaint.priority == 'Critical'
              ? Colors.red
              : complaint.priority == 'High'
                  ? Colors.deepOrange
                  : Colors.orange;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.transparent),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ComplaintDetailsScreen(complaint: complaint),
                    ),
                  ).then((_) => _fetchComplaints());
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    complaint.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? Colors.white : AppTheme.secondaryColor,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_submittedOfferIds.contains(complaint.id))
                                  Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.green.shade100),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.check_circle_outline, color: Colors.green, size: 10),
                                        SizedBox(width: 3),
                                        Text(
                                          'Bid Active',
                                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 8),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              complaint.priority,
                              style: TextStyle(
                                color: isDark ? priorityColor.shade300 : priorityColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        complaint.description,
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.thumb_up_outlined, color: isDark ? Colors.grey.shade400 : Colors.grey, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '${complaint.likesCount} Support',
                                style: TextStyle(
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            DateFormat('dd MMM yyyy').format(complaint.createdAt ?? DateTime.now()),
                            style: TextStyle(
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
