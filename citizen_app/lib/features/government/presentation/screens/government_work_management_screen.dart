import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/government/domain/models/work_task_model.dart';
import 'package:sadak_sevak_citizen/features/government/presentation/screens/government_work_details_screen.dart';

class GovernmentWorkManagementScreen extends StatefulWidget {
  const GovernmentWorkManagementScreen({super.key});

  @override
  State<GovernmentWorkManagementScreen> createState() => _GovernmentWorkManagementScreenState();
}

class _GovernmentWorkManagementScreenState extends State<GovernmentWorkManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GovernmentRepository _repository = GovernmentRepository();

  bool _isLoading = true;
  List<WorkTaskModel> _works = [];
  String selectedStatus = 'All Status';

  @override
  void initState() {
    super.initState();
    _fetchWorks();
  }

  Future<void> _fetchWorks() async {
    try {
      final works = await _repository.getWorkTasks();
      setState(() {
        _works = works;
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

    List<WorkTaskModel> filteredWorks = _works.where((work) {
      final matchesSearch = work.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          work.id.toLowerCase().contains(_searchController.text.toLowerCase());
      final matchesStatus = selectedStatus == 'All Status' || work.status.toLowerCase() == selectedStatus.toLowerCase();
      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
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
                        child: const Icon(Icons.engineering_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Work Management',
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
                    '${filteredWorks.length} tasks found',
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
                        hintText: 'Search work by ID or title...',
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
                            const PopupMenuItem<String>(value: 'In Progress', child: Text('In Progress', style: TextStyle(color: Colors.black87))),
                            const PopupMenuItem<String>(value: 'Completed', child: Text('Completed', style: TextStyle(color: Colors.black87))),
                            const PopupMenuItem<String>(value: 'On Hold', child: Text('On Hold', style: TextStyle(color: Colors.black87))),
                            const PopupMenuItem<String>(value: 'Assigned', child: Text('Assigned', style: TextStyle(color: Colors.black87))),
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
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: primaryOrange))
              : _buildWorkList(filteredWorks),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: primaryOrange,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Work',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }

  Widget _buildWorkList(List<WorkTaskModel> list) {

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.engineering_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'No work orders found',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final work = list[index];
        final int percentVal = work.progress;
        final double progressVal = percentVal / 100.0;

        return FadeInUp(
          duration: const Duration(milliseconds: 300),
          delay: Duration(milliseconds: 50 * index),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GovernmentWorkDetailsScreen(task: work),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
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
                        work.id,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      _buildStatusBadge(work.status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    work.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Team: ${work.team}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: progressVal,
                            color: work.status == 'Completed' ? Colors.green : const Color(0xFFF4511E),
                            backgroundColor: Colors.grey.shade100,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$percentVal%',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF263238), fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color bgColor;
    switch (status.toLowerCase()) {
      case 'completed':
        color = const Color(0xFF43A047);
        bgColor = const Color(0xFFE8F5E9);
        break;
      case 'in progress':
        color = const Color(0xFFF4511E);
        bgColor = const Color(0xFFFFF3E0);
        break;
      case 'on hold':
        color = const Color(0xFFFB8C00);
        bgColor = const Color(0xFFFFFDE7);
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
}
