import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sadak_sevak_citizen/features/report/presentation/screens/report_issue_screen.dart';
import 'package:sadak_sevak_citizen/features/government/presentation/screens/government_complaint_details_screen.dart';

import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/complaints/domain/complaint_model.dart';
import 'package:intl/intl.dart';

class GovernmentComplaintsScreen extends StatefulWidget {
  const GovernmentComplaintsScreen({super.key});

  @override
  State<GovernmentComplaintsScreen> createState() => _GovernmentComplaintsScreenState();
}

class _GovernmentComplaintsScreenState extends State<GovernmentComplaintsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GovernmentRepository _repository = GovernmentRepository();
  String selectedStatus = 'All Status';
  String selectedCategory = 'All Category';

  bool _isLoading = true;
  String? _errorMessage;
  List<Complaint> _complaints = [];

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final complaints = await _repository.getComplaints();
      setState(() {
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load complaints. Make sure you are logged in as an Admin or Department Head.\n\nError: $e';
      });
    }
  }


  void _showAddComplaintOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Register New Complaint',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Color(0xFFFFF3E0), shape: BoxShape.circle),
                    child: const Icon(Icons.flash_on_rounded, color: Color(0xFFF4511E)),
                  ),
                  title: const Text('Quick Log Complaint', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Instantly log an issue in the active database'),
                  onTap: () {
                    Navigator.pop(context);
                    _showQuickAddDialog();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                    child: Icon(Icons.add_photo_alternate_rounded, color: Colors.blue.shade600),
                  ),
                  title: const Text('Detailed Report (Citizen flow)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Report with photos, GPS location & details'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReportIssueScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQuickAddDialog() {
    final titleController = TextEditingController();
    String priorityVal = 'High';
    String statusVal = 'Assigned';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Quick Log Complaint', style: TextStyle(fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Complaint Title / Location', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'e.g. Pothole - University Road',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Priority Level', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['High', 'Medium', 'Low'].map((p) {
                      final isSel = priorityVal == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(p),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) setDialogState(() => priorityVal = p);
                          },
                          selectedColor: const Color(0xFFF4511E),
                          labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                final newId = 'CMP-2024-00${_complaints.length + 1}';
                setState(() {
                  // We should ideally call the API, but for quick mock:
                  // final mockComplaint = Complaint(id: newId, title: titleController.text.trim(), ...);
                  // _complaints.insert(0, mockComplaint);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully logged $newId!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF4511E)),
              child: const Text('Log Issue', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);
    const darkOrange = Color(0xFFD84315);

    List<Complaint> filteredComplaints = _complaints.where((complaint) {
      final matchesSearch = complaint.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          complaint.id.toLowerCase().contains(_searchController.text.toLowerCase());
      
      // Map backend status to government UI status groups
      String compStatus = _getGovernmentStatusCategory(complaint.status);
      final matchesStatus = selectedStatus == 'All Status' || compStatus.toLowerCase() == selectedStatus.toLowerCase();
      
      String catKey = selectedCategory;
      if (catKey == 'All Category') {
        return matchesSearch && matchesStatus;
      }
      final matchesCategory = complaint.title.toLowerCase().contains(catKey.replaceAll('Category', '').trim().toLowerCase())
          || complaint.category.toLowerCase().contains(catKey.replaceAll('Category', '').trim().toLowerCase());
      return matchesSearch && matchesStatus && matchesCategory;
    }).toList();

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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white30, width: 1.5),
                            ),
                            child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Complaints',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      // Add Button
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        elevation: 2,
                        child: InkWell(
                          onTap: _showAddComplaintOptions,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 18, color: primaryOrange),
                                SizedBox(width: 4),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    color: primaryOrange,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${filteredComplaints.length} complaints found',
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
                        hintText: 'Search by ID or location...',
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: PopupMenuButton<String>(
                          initialValue: selectedCategory,
                          onSelected: (String item) {
                            setState(() => selectedCategory = item);
                          },
                          offset: const Offset(0, 48),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          itemBuilder: (BuildContext context) {
                            final Set<String> categoriesSet = {'All Category'};
                            for (var c in _complaints) {
                              if (c.category.isNotEmpty) {
                                categoriesSet.add(c.category);
                              }
                            }
                            return categoriesSet.map((cat) {
                              return PopupMenuItem<String>(
                                value: cat,
                                child: Text(cat, style: const TextStyle(color: Colors.black87)),
                              );
                            }).toList();
                          },
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
                                    selectedCategory,
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

          // Complaints List
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: primaryOrange))
              : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_outline_rounded, size: 56, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Could not load complaints',
                            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _fetchComplaints,
                            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                            label: const Text('Retry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(backgroundColor: primaryOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          ),
                        ],
                      ),
                    ),
                  )
              : filteredComplaints.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 56, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No complaints found',
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
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
                    itemCount: filteredComplaints.length,
                    itemBuilder: (context, index) {
                      final complaint = filteredComplaints[index];
                      final displayDate = complaint.createdAt != null 
                        ? DateFormat('MMM dd, yyyy').format(complaint.createdAt!) 
                        : 'Unknown Date';
                        
                      return FadeInUp(
                        duration: const Duration(milliseconds: 300),
                        delay: Duration(milliseconds: 50 * index),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GovernmentComplaintDetailsScreen(complaint: complaint),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF3E0),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      complaint.id.substring(0, complaint.id.length > 8 ? 8 : complaint.id.length),
                                      style: const TextStyle(
                                        color: primaryOrange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                complaint.title,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1F5FE),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  complaint.category.isNotEmpty ? complaint.category : 'General',
                                  style: const TextStyle(
                                    color: Color(0xFF0277BD),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      _buildPriorityBadge(complaint.priority),
                                      const SizedBox(width: 8),
                                      _buildStatusBadge(_getGovernmentDisplayStatus(complaint.status)),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 12, color: Colors.grey.shade400),
                                      const SizedBox(width: 4),
                                      Text(
                                        displayDate,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    Color bgColor;
    switch (priority.toLowerCase()) {
      case 'high':
        color = const Color(0xFFE53935);
        bgColor = const Color(0xFFFFEBEE);
        break;
      case 'medium':
        color = const Color(0xFFFB8C00);
        bgColor = const Color(0xFFFFF3E0);
        break;
      default:
        color = const Color(0xFF43A047);
        bgColor = const Color(0xFFE8F5E9);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    switch (status.toLowerCase()) {
      case 'complete':
        color = const Color(0xFF43A047);
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 'in progress':
        color = const Color(0xFF1E88E5);
        bgColor = const Color(0xFFE3F2FD);
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
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getGovernmentStatusCategory(String status) {
    final lower = status.toLowerCase();
    if (lower == 'repair_completed' || lower == 'verified_closed') {
      return 'Complete';
    }
    if (lower == 'team_assigned' || lower == 'repair_started' || lower == 'repair_in_progress') {
      return 'In Progress';
    }
    return 'Pending';
  }

  String _getGovernmentDisplayStatus(String status) {
    return _getGovernmentStatusCategory(status);
  }
}
