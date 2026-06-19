import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:sadak_sevak_citizen/core/network/socket_service.dart';
import 'package:sadak_sevak_citizen/features/home/data/notification_repository.dart';
import 'package:sadak_sevak_citizen/features/complaints/data/complaint_repository.dart';
import 'package:sadak_sevak_citizen/features/complaints/domain/complaint_model.dart';
import 'package:sadak_sevak_citizen/features/complaints/presentation/screens/complaints_list_screen.dart';
import 'package:sadak_sevak_citizen/features/report/presentation/screens/report_issue_screen.dart';
import 'package:sadak_sevak_citizen/features/complaints/presentation/screens/complaint_details_screen.dart';
import 'package:sadak_sevak_citizen/features/map/presentation/screens/map_screen.dart';
import 'package:sadak_sevak_citizen/features/home/presentation/screens/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Citizen';
  final _complaintRepo = ComplaintRepository();
  final _notifyRepo = NotificationRepository();
  List<Complaint> _recentComplaints = [];
  bool _isLoadingComplaints = true;
  int _unreadCount = 0;
  StreamSubscription<dynamic>? _notificationSub;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadRecentComplaints();
    _loadUnreadCount();
    _notificationSub = SocketService().notificationStream.listen((_) {
      if (mounted) {
        _loadUnreadCount();
      }
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _notifyRepo.getUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'Citizen';
    if (mounted) setState(() => _userName = name.split(' ').first);
  }

  Future<void> _loadRecentComplaints() async {
    try {
      final complaints = await _complaintRepo.getAllComplaints();
      if (mounted) {
        setState(() {
          _recentComplaints = complaints.take(3).toList();
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUser();
          await _loadRecentComplaints();
        },
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildReportBanner(context),
              _buildQuickActions(context),
              _buildRecentReportsHeader(),
              _buildRecentReportsList(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
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
                child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInLeft(
                    child: Text(
                      'Hello, $_userName 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Text(
                    "Let's make our roads better",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
              _loadUnreadCount();
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                ),
                if (_unreadCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        _unreadCount > 99 ? '99+' : '$_unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportBanner(BuildContext context) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.report_gmailerrorred_rounded, color: AppTheme.primaryColor, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Report a New Issue',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Help us improve road quality across your city.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReportIssueScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Report Now >', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.add_road_rounded, size: 60, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  context,
                  title: 'My Reports',
                  subtitle: 'Track status',
                  icon: Icons.list_alt_rounded,
                  color: const Color(0xFF00A75D),
                  bgColor: const Color(0xFFE8F6EE),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ComplaintsListScreen()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  title: 'Nearby',
                  subtitle: 'Within 5km',
                  icon: Icons.near_me_rounded,
                  color: const Color(0xFFF4511E),
                  bgColor: const Color(0xFFFDF0ED),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen(initialCategory: 'Nearby')),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  context,
                  title: 'Live Map',
                  subtitle: 'Explore zone',
                  icon: Icons.map_rounded,
                  color: const Color(0xFF0D47A1),
                  bgColor: const Color(0xFFEEF2FA),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen()),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.secondaryColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentReportsHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Reports',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ComplaintsListScreen()),
            ),
            child: const Text(
              'See All',
              style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportsList(BuildContext context) {
    if (_isLoadingComplaints) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(20.0),
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ));
    }

    if (_recentComplaints.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Icon(Icons.description_outlined, size: 50, color: Colors.grey.shade300),
              const SizedBox(height: 10),
              Text('No reports found', style: TextStyle(color: Colors.grey.shade400)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _recentComplaints.map((report) => _buildReportCard(context, report)).toList(),
    );
  }

  Widget _buildReportCard(BuildContext context, Complaint report) {
    final statusLabel = _getSimpleStatusLabel(report.status);
    final statusColor = _getSimpleStatusColor(report.status);
    final statusIcon = _getSimpleStatusIcon(report.status);

    final displayDate = report.createdAt != null
        ? '${report.createdAt!.day} ${_getMonth(report.createdAt!.month)} ${report.createdAt!.year}'
        : 'Recent';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
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
                builder: (context) => ComplaintDetailsScreen(complaint: report),
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
                          '#${report.id.length > 8 ? report.id.substring(0, 8) : report.id}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondaryColor),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  report.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                if (report.citizenName != null && report.citizenName!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Reported by: ${report.citizenName}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 6),
                    Text(
                      displayDate,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w400),
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

  String _getMonth(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _getStatusText(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'pending':
        return 'Pending';
      case 'under_review':
        return 'Under Review';
      case 'escalated':
        return 'Escalated';
      case 'team_assigned':
      case 'in_progress':
      case 'work_in_progress':
      case 'repair_started':
      case 'repair_in_progress':
        return 'In Progress';
      case 'repair_completed':
      case 'verified_closed':
      case 'resolved':
      case 'completed':
        return 'Complete';
      case 'reopened':
        return 'Reopened';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _getStatusCategory(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'under_review':
      case 'pending':
        return 'Pending';
      case 'team_assigned':
      case 'in_progress':
      case 'work_in_progress':
      case 'repair_started':
      case 'repair_in_progress':
      case 'escalated':
        return 'In Progress';
      case 'repair_completed':
      case 'verified_closed':
      case 'resolved':
      case 'completed':
        return 'Complete';
      case 'reopened':
        return 'Reopened';
      default:
        return 'Unknown';
    }
  }
}
