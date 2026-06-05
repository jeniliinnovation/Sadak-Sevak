import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sadak_sevak_citizen/features/complaints/data/complaint_repository.dart';
import 'package:sadak_sevak_citizen/features/complaints/domain/complaint_model.dart';
import 'package:sadak_sevak_citizen/features/complaints/presentation/screens/complaints_list_screen.dart';
import 'package:sadak_sevak_citizen/features/report/presentation/screens/report_issue_screen.dart';
import 'package:sadak_sevak_citizen/features/complaints/presentation/screens/complaint_details_screen.dart';
import 'package:sadak_sevak_citizen/features/map/presentation/screens/map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'Citizen';
  final _complaintRepo = ComplaintRepository();
  List<Complaint> _recentComplaints = [];
  bool _isLoadingComplaints = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadRecentComplaints();
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
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionItem(context, Icons.list_alt_rounded, 'My Complaints'),
              _buildActionItem(context, Icons.near_me_rounded, 'Nearby Issues'),
              _buildActionItem(context, Icons.traffic_rounded, 'Road Status'),
              _buildActionItem(context, Icons.map_rounded, 'Live Map'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'My Complaints' || label == 'Road Status') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ComplaintsListScreen()),
          );
        } else if (label == 'Nearby Issues') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen(initialCategory: 'Nearby')),
          );
        } else if (label == 'Live Map') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MapScreen()),
          );
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w500),
          ),
        ],
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
    Color statusColor;
    switch (report.status.toLowerCase()) {
      case 'resolved': statusColor = Colors.green; break;
      case 'rejected': statusColor = Colors.red; break;
      case 'verified_closed': statusColor = Colors.blue; break;
      default: statusColor = Colors.orange;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComplaintDetailsScreen(complaint: report),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.report_problem_outlined, color: statusColor, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.secondaryColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${report.id.length > 8 ? report.id.substring(0, 8).toUpperCase() : report.id.toUpperCase()} • ${report.createdAt?.toString().substring(0, 10) ?? 'Just now'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                report.status.replaceAll('_', ' ').toUpperCase(),
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
    );
  }
}
