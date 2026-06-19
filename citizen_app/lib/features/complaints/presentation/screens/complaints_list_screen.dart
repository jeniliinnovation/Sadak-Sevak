import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:sadak_sevak_citizen/features/complaints/presentation/screens/complaint_details_screen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/complaint_repository.dart';
import '../../domain/complaint_model.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  final _complaintRepo = ComplaintRepository();
  final TextEditingController _userSearchController = TextEditingController();
  List<Complaint> _complaints = [];
  bool _isLoading = true;
  String _userRole = 'citizen';
  String _selectedListType = 'my';
  String _selectedStatus = 'all';
  String _userSearchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadUserRoleAndComplaints();
  }

  Future<void> _loadUserRoleAndComplaints() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role')?.toLowerCase() ?? 'citizen';
    setState(() => _userRole = role);
    await _fetchComplaints();
  }

  @override
  void dispose() {
    _userSearchController.dispose();
    super.dispose();
  }

  Future<void> _fetchComplaints() async {
    setState(() => _isLoading = true);
    try {
      final data = _selectedListType == 'all'
          ? await _complaintRepo.getAllComplaints()
          : await _complaintRepo.getMyComplaints();
      if (mounted) setState(() => _complaints = data);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text(
          _selectedListType == 'all' ? 'All Complaints' : 'My Complaints',
          style: const TextStyle(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppTheme.secondaryColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16,
                  ),
                  child: Column(
                    children: [
                      _buildListTypeSwitcher(),
                      const SizedBox(height: 8),
                      _buildStatusSwitcher(),
                      const SizedBox(height: 8),
                      _buildUserSearchField(),
                    ],
                  ),
                ),
                Expanded(child: _buildList()),
              ],
            ),
    );
  }

  Widget _buildListTypeSwitcher() {
    final items = [
      {'value': 'my', 'label': 'My Complaints'},
      {'value': 'all', 'label': 'All Complaints'},
    ];

    return Row(
      children: items.map((item) {
        final value = item['value']!;
        final label = item['label']!;
        final isSelected = _selectedListType == value;
        return Expanded(
          child: GestureDetector(
            onTap: () async {
              if (_selectedListType != value) {
                setState(() {
                  _selectedListType = value;
                  _selectedStatus = 'all';
                });
                await _fetchComplaints();
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.grey.shade200,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusSwitcher() {
    final items = [
      {'value': 'all', 'label': 'All'},
      {'value': 'pending', 'label': 'Pending'},
      {'value': 'in_progress', 'label': 'In Progress'},
      {'value': 'complete', 'label': 'Complete'},
    ];

    return Row(
      children: items.map((item) {
        final value = item['value']!;
        final label = item['label']!;
        final isSelected = _selectedStatus == value;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedStatus = value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : Colors.grey.shade200,
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildList() {
    final statuses = _getStatusesForSection(_selectedStatus);
    final filtered = _complaints.where((r) {
      final statusMatch = statuses == null || statuses.contains(r.status);
      final searchLower = _userSearchTerm.trim().toLowerCase();
      final userMatch =
          searchLower.isEmpty ||
          r.title.toLowerCase().contains(searchLower) ||
          r.id.toLowerCase().contains(searchLower) ||
          (r.citizenName?.toLowerCase().contains(searchLower) ?? false);
      return statusMatch && userMatch;
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No complaints found',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchComplaints,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          return FadeInUp(
            duration: Duration(milliseconds: 300 + (index * 80)),
            child: _buildComplaintCard(filtered[index]),
          );
        },
      ),
    );
  }

  Widget _buildComplaintCard(Complaint complaint) {
    final displayStatus = _getSimpleStatusLabel(complaint.status);
    final statusColor = _getSimpleStatusColor(complaint.status);
    final statusIcon = _getSimpleStatusIcon(complaint.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ComplaintDetailsScreen(complaint: complaint),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 8),
                        Text(
                          '#${complaint.id.length > 8 ? complaint.id.substring(0, 8) : complaint.id}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        displayStatus,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  complaint.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                if (complaint.citizenName != null &&
                    complaint.citizenName!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Reported by: ${complaint.citizenName}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      complaint.createdAt != null
                          ? '${complaint.createdAt!.day} ${_getMonth(complaint.createdAt!.month)} ${complaint.createdAt!.year}'
                          : 'Recent',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
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
  }

  List<String>? _getStatusesForSection(String? section) {
    if (section == null || section == 'all') return null;
    switch (section) {
      case 'pending':
        return ['pending', 'submitted', 'under_review'];
      case 'citizen':
        return ['submitted'];
      case 'team':
        return ['team_assigned', 'repair_started', 'repair_in_progress'];
      case 'govt':
        return ['under_review'];
      case 'in_progress':
        return ['team_assigned', 'repair_started', 'repair_in_progress'];
      case 'complete':
        return ['repair_completed', 'verified_closed'];
      default:
        return null;
    }
  }

  String _getSimpleStatusLabel(String status) {
    final lower = status.toLowerCase();
    if (lower == 'repair_completed' || lower == 'verified_closed') {
      return 'COMPLETE';
    }
    if (lower == 'team_assigned' || lower == 'repair_started' || lower == 'repair_in_progress') {
      return 'IN PROGRESS';
    }
    return 'PENDING';
  }

  Color _getSimpleStatusColor(String status) {
    final lower = status.toLowerCase();
    if (lower == 'repair_completed' || lower == 'verified_closed') {
      return Colors.green.shade700;
    }
    if (lower == 'team_assigned' || lower == 'repair_started' || lower == 'repair_in_progress') {
      return Colors.blue.shade700;
    }
    return Colors.orange.shade700;
  }

  IconData _getSimpleStatusIcon(String status) {
    final lower = status.toLowerCase();
    if (lower == 'repair_completed' || lower == 'verified_closed') {
      return Icons.check_circle_rounded;
    }
    if (lower == 'team_assigned' || lower == 'repair_started' || lower == 'repair_in_progress') {
      return Icons.construction_rounded;
    }
    return Icons.hourglass_top_rounded;
  }

  Widget _buildUserSearchField() {
    return TextField(
      controller: _userSearchController,
      onChanged: (value) => setState(() => _userSearchTerm = value),
      decoration: InputDecoration(
        hintText: 'Search by user name, complaint title, or ID',
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
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
    return months[month - 1];
  }
}
