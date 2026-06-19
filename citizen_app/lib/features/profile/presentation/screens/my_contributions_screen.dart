import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:sadak_sevak_citizen/features/home/data/notification_repository.dart';
import 'package:sadak_sevak_citizen/features/complaints/data/complaint_repository.dart';

class MyContributionsScreen extends StatefulWidget {
  const MyContributionsScreen({super.key});

  @override
  State<MyContributionsScreen> createState() => _MyContributionsScreenState();
}

class _MyContributionsScreenState extends State<MyContributionsScreen> {
  final _complaintsRepo = ComplaintRepository();
  List<dynamic> _complaints = [];
  bool _isLoading = true;

  // Stats
  int _totalReported = 0;
  int _resolved = 0;
  int _inProgress = 0;
  int _pending = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final complaints = await _complaintsRepo.getMyComplaints();
      int resolved = 0, inProgress = 0, pending = 0;
      for (var c in complaints) {
        final status = (c.status ?? '').toLowerCase();
        if (status == 'verified_closed' || status == 'repair_completed') resolved++;
        else if (status == 'repair_started' || status == 'team_assigned') inProgress++;
        else pending++;
      }
      if (mounted) {
        setState(() {
          _complaints = complaints;
          _totalReported = complaints.length;
          _resolved = resolved;
          _inProgress = inProgress;
          _pending = pending;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.secondaryColor),
        ),
        title: const Text('My Contributions',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 18)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Stats header
                  FadeInDown(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6)),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.volunteer_activism_rounded, color: Colors.white, size: 22),
                              SizedBox(width: 8),
                              Text('Your Impact', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statItem('$_totalReported', 'Reported', Icons.report_outlined),
                              _divider(),
                              _statItem('$_resolved', 'Resolved', Icons.check_circle_outline_rounded),
                              _divider(),
                              _statItem('$_inProgress', 'In Progress', Icons.pending_outlined),
                              _divider(),
                              _statItem('$_pending', 'Pending', Icons.hourglass_top_rounded),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Achievement badges
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🏆 Achievements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.secondaryColor)),
                          const SizedBox(height: 14),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _badge('🌱', 'First Report', _totalReported >= 1, 'Submit your first report'),
                                const SizedBox(width: 10),
                                _badge('⭐', 'Active Citizen', _totalReported >= 3, 'Report 3 issues'),
                                const SizedBox(width: 10),
                                _badge('🏅', 'Community Hero', _resolved >= 3, 'Get 3 resolved'),
                                const SizedBox(width: 10),
                                _badge('🚀', 'Road Warrior', _totalReported >= 10, 'Report 10 issues'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Complaints list
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12)],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text('Reported Issues (${_complaints.length})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.secondaryColor)),
                          ),
                          if (_complaints.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(Icons.inbox_rounded, size: 48, color: Color(0xFFCCE8D8)),
                                    SizedBox(height: 8),
                                    Text('No reports yet', style: TextStyle(color: Colors.grey, fontSize: 14)),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...(_complaints.map((c) => _complaintTile(c))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _divider() {
    return Container(height: 40, width: 1, color: Colors.white24);
  }

  Widget _badge(String emoji, String title, bool unlocked, String description) {
    return Container(
      width: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? AppTheme.primaryColor.withOpacity(0.08) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: unlocked ? AppTheme.primaryColor.withOpacity(0.2) : Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Text(unlocked ? emoji : '🔒', style: const TextStyle(fontSize: 26)),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: unlocked ? AppTheme.secondaryColor : Colors.grey.shade400)),
          const SizedBox(height: 2),
          Text(description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _complaintTile(dynamic c) {
    final status = (c.status ?? '').toLowerCase();
    Color statusColor;
    String statusLabel;
    if (status == 'verified_closed' || status == 'repair_completed') {
      statusColor = AppTheme.primaryColor;
      statusLabel = 'Resolved';
    } else if (status == 'repair_started' || status == 'team_assigned') {
      statusColor = Colors.orange;
      statusLabel = 'In Progress';
    } else {
      statusColor = Colors.blue;
      statusLabel = 'Pending';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.report_problem_outlined, color: statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.title ?? 'Complaint', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondaryColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(c.category ?? '', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
          ),
        ],
      ),
    );
  }
}
