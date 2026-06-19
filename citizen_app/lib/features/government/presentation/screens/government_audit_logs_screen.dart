import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/government/domain/models/audit_log_model.dart';

class GovernmentAuditLogsScreen extends StatefulWidget {
  const GovernmentAuditLogsScreen({super.key});

  @override
  State<GovernmentAuditLogsScreen> createState() => _GovernmentAuditLogsScreenState();
}

class _GovernmentAuditLogsScreenState extends State<GovernmentAuditLogsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GovernmentRepository _repository = GovernmentRepository();

  String selectedActionFilter = 'All Actions';
  bool _isLoading = true;
  List<AuditLogModel> _logs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    try {
      final logs = await _repository.getAuditLogs();
      setState(() {
        _logs = logs;
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

    final filteredLogs = _logs.where((log) {
      // Search filter
      final matchesSearch = log.action.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          log.user.toLowerCase().contains(_searchController.text.toLowerCase());

      // Action filter
      if (selectedActionFilter == 'All Actions') return matchesSearch;
      final actionLower = log.action.toLowerCase();
      if (selectedActionFilter == 'Create' && actionLower.contains('create')) return matchesSearch;
      if (selectedActionFilter == 'Update' && actionLower.contains('update')) return matchesSearch;
      if (selectedActionFilter == 'Approve' && (actionLower.contains('approve') || actionLower.contains('assign'))) return matchesSearch;
      if (selectedActionFilter == 'Reports' && actionLower.contains('report')) return matchesSearch;
      return false;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Audit Logs',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),      body: Column(
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
                        child: const Icon(Icons.history_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Audit Logs',
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
                    '${filteredLogs.length} logs found',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
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
                        hintText: 'Search logs by action or user...',
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
                          initialValue: selectedActionFilter,
                          onSelected: (String item) {
                            setState(() => selectedActionFilter = item);
                          },
                          offset: const Offset(0, 48),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(value: 'All Actions', child: Text('All Actions', style: TextStyle(color: Colors.black87))),
                            const PopupMenuItem<String>(value: 'Create', child: Text('Create', style: TextStyle(color: Colors.black87))),
                            const PopupMenuItem<String>(value: 'Update', child: Text('Update', style: TextStyle(color: Colors.black87))),
                            const PopupMenuItem<String>(value: 'Approve', child: Text('Approve', style: TextStyle(color: Colors.black87))),
                            const PopupMenuItem<String>(value: 'Reports', child: Text('Reports', style: TextStyle(color: Colors.black87))),
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
                                    selectedActionFilter,
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

          // Logs timeline
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryOrange))
                : filteredLogs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history_toggle_off_rounded, size: 56, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No logs found',
                              style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];

                          // Icon logic based on text
                          IconData icon = Icons.info_outline;
                          Color color = Colors.grey;
                          final actionLower = log.action.toLowerCase();
                          if (actionLower.contains('create')) { icon = Icons.add_circle_outline_rounded; color = Colors.orange; }
                          else if (actionLower.contains('update')) { icon = Icons.sync_rounded; color = Colors.blue; }
                          else if (actionLower.contains('approve') || actionLower.contains('assign')) { icon = Icons.check_circle_outline_rounded; color = Colors.green; }
                          else if (actionLower.contains('report')) { icon = Icons.analytics_outlined; color = Colors.purple; }

                          final isLast = index == filteredLogs.length - 1;
                          return FadeInUp(
                            duration: const Duration(milliseconds: 300),
                            delay: Duration(milliseconds: 40 * index),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Timeline Line and Node
                                  SizedBox(
                                    width: 40,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          margin: const EdgeInsets.only(top: 8),
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                            border: Border.all(color: color, width: 2),
                                          ),
                                          child: Icon(icon, color: color, size: 12),
                                        ),
                                        if (!isLast)
                                          Expanded(
                                            child: Container(
                                              width: 2,
                                              margin: const EdgeInsets.only(top: 4, bottom: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade200,
                                                borderRadius: BorderRadius.circular(1),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Log Card Content
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
                                        ],
                                        border: Border.all(color: Colors.grey.shade100),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                log.user,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF263238)),
                                              ),
                                              Text(
                                                log.timestamp,
                                                style: TextStyle(color: Colors.grey.shade400, fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            log.action,
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
