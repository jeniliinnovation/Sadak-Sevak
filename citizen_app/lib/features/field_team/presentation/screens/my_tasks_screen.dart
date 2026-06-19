import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../complaints/domain/complaint_model.dart';
import '../../../complaints/presentation/screens/complaint_details_screen.dart';
import '../../../government/data/government_repository.dart';

class MyTasksScreen extends StatefulWidget {
  const MyTasksScreen({super.key});

  @override
  State<MyTasksScreen> createState() => _MyTasksScreenState();
}

class _MyTasksScreenState extends State<MyTasksScreen> {
  String _selectedView = 'My Tasks';
  String _selectedFilter = 'All';
  final _repository = GovernmentRepository();
  List<Complaint> _allAssignedComplaints = [];
  List<Complaint> _taskComplaintsList = [];
  List<Complaint> _complaintItemsList = [];
  bool _isLoading = true;

  static const Color _blue = Color(0xFF4A80F0);
  static const Color _darkBlue = Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    try {
      final activeTasks = await _repository.getAssignedTasks();
      final completedTasks = await _repository.getAssignedCompletedComplaints();

      if (mounted) {
        setState(() {
          _taskComplaintsList = activeTasks;
          _complaintItemsList = completedTasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Complaint> get _taskComplaints {
    return _taskComplaintsList;
  }

  List<Complaint> get _complaintItems {
    return _complaintItemsList;
  }

  List<Complaint> get _filtered {
    final list = _selectedView == 'My Tasks' ? _taskComplaints : _complaintItems;
    if (_selectedFilter == 'All') return list;
    if (_selectedFilter == 'Pending') {
      return list.where((c) {
        final status = c.status.toLowerCase();
        return status == 'submitted' || status == 'pending' || status == 'under_review';
      }).toList();
    }
    if (_selectedFilter == 'In Progress') {
      return list.where((c) {
        final status = c.status.toLowerCase();
        return status == 'team_assigned' || status == 'repair_started' || status == 'repair_in_progress';
      }).toList();
    }
    // Completed
    return list.where((c) {
      final status = c.status.toLowerCase();
      return status == 'repair_completed' || status == 'verified_closed';
    }).toList();
  }

  Widget _buildViewSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(child: _viewChip('My Tasks')),
          const SizedBox(width: 10),
          Expanded(child: _viewChip('My Complaints')),
        ],
      ),
    );
  }

  Widget _viewChip(String label) {
    final selected = _selectedView == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? _blue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? _blue : Colors.grey.shade200),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _blue));
    }

    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Text(
          _selectedView == 'My Tasks'
              ? 'No tasks found for "$_selectedFilter".'
              : 'No complaints found for "$_selectedFilter".',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final complaint = items[i];
        return FadeInUp(
          key: ValueKey(complaint.id),
          delay: Duration(milliseconds: i * 60),
          child: _taskCard(context, complaint),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(_selectedView,
            style: const TextStyle(
                color: _darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _darkBlue),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadComplaints();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _buildViewSelector(),
          const SizedBox(height: 10),
          // Filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _chip('All'),
                  const SizedBox(width: 10),
                  _chip('Pending'),
                  const SizedBox(width: 10),
                  _chip('In Progress'),
                  const SizedBox(width: 10),
                  _chip('Completed'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(child: _buildCurrentContent()),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    final selected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? _blue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? _blue : Colors.grey.shade200),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: _blue.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

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

    final lowerStatus = complaint.status.toLowerCase();
    if (lowerStatus == 'team_assigned' || lowerStatus == 'repair_started' || lowerStatus == 'repair_in_progress') {
      status = 'In Progress';
      statusColor = _blue;
      statusBg = const Color(0xFFEEF3FF);
    } else if (lowerStatus == 'repair_completed' || lowerStatus == 'verified_closed') {
      status = 'Completed';
      statusColor = Colors.green;
      statusBg = Colors.green.shade50;
    }

    final locationText = complaint.location['address'] ?? complaint.location['area'] ?? 'Unknown location';
    final hasLocation = complaint.location['area'] != null || complaint.location['address'] != null;
    final locationBadge = hasLocation ? 'Verified location' : 'Location unknown';
    final teamName = complaint.assignedTeamName?.isNotEmpty == true
        ? complaint.assignedTeamName!
        : (complaint.assignedTeamId ?? 'Unassigned');
    final statusLabel = lowerStatus == 'team_assigned' || lowerStatus == 'repair_started' || lowerStatus == 'repair_in_progress'
        ? 'In Progress'
        : lowerStatus == 'repair_completed' || lowerStatus == 'verified_closed'
            ? 'Completed'
            : 'Pending';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ComplaintDetailsScreen(complaint: complaint)),
      ),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                      color: const Color(0xFFEEF3FF),
                      borderRadius: BorderRadius.circular(12)),
                  child: Icon(icon, color: _blue, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(complaint.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 6),
                      Text('$locationBadge near $locationText${_coordsString(complaint)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(status,
                      style: TextStyle(
                          color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${complaint.priority[0].toUpperCase()}${complaint.priority.substring(1)} Priority',
                    style: TextStyle(color: priorityColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Team: $teamName',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Status: $statusLabel', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  String _coordsString(Complaint complaint) {
    try {
      final lat = complaint.location['lat'] ?? complaint.location['latitude'] ?? complaint.location['latitude'];
      final lng = complaint.location['lng'] ?? complaint.location['longitude'] ?? complaint.location['lon'];
      if (lat != null && lng != null) {
        return ' (${lat.toString()}, ${lng.toString()})';
      }
    } catch (_) {}
    return '';
  }
}
