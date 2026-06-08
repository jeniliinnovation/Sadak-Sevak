import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'update_task_screen.dart';
import '../../../complaints/domain/complaint_model.dart';
import '../../../complaints/presentation/screens/complaint_chat_screen.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Complaint? complaint;

  const TaskDetailsScreen({super.key, this.complaint});

  static const Color _blue = Color(0xFF4A80F0);
  static const Color _darkBlue = Color(0xFF0D47A1);

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = complaint?.title ?? 'Road Damage';
    final address = complaint?.location['address'] ?? 'NH-48, Delhi – Jaipur';
    final description = complaint?.description ?? 'Large pothole causing traffic disruption and vehicle damage. Immediate repair required. Check nearby drainage system for overflow.';
    final priority = complaint?.priority ?? 'High';
    final priorityColor = _getPriorityColor(priority);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Task Details',
            style: TextStyle(
                color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Title & Priority ──────────────────────────────────
            FadeInDown(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: const Color(0xFFEEF3FF),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.report_problem_outlined,
                            color: _blue, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _darkBlue)),
                            Text(address,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text('$priority Priority',
                        style: TextStyle(
                            color: priorityColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Divider(color: Colors.grey.shade100),
            const SizedBox(height: 16),

            // ─── Info Rows ─────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: _infoTable(),
            ),

            const SizedBox(height: 24),

            // ─── Description ───────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _darkBlue)),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                        height: 1.6),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Map Preview ────────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Location',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: _darkBlue)),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.map_outlined,
                            size: 16, color: _blue),
                        label: const Text('View on Map',
                            style:
                                TextStyle(color: _blue, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            'https://tile.openstreetmap.org/13/6574/3171.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFDDE8F8),
                              child: const Center(
                                  child: Icon(Icons.map_outlined,
                                      size: 60, color: Color(0xFF4A80F0))),
                            ),
                          ),
                        ),
                        const Center(
                          child: Icon(Icons.location_on,
                              color: Colors.red, size: 36),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Images Section ─────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 240),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Images',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _darkBlue)),
                  const SizedBox(height: 10),
                  if (complaint != null && complaint!.mediaList.isNotEmpty)
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: complaint!.mediaList.length,
                        itemBuilder: (context, i) {
                          final url = complaint!.mediaList[i]['url'] as String?;
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  url ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.image_outlined,
                                      color: Colors.grey.shade400, size: 28),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Row(
                      children: List.generate(
                        2,
                        (i) => Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.image_outlined,
                                color: Colors.grey.shade400, size: 28),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Work Status Timeline ────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 280),
              child: _buildWorkStatusTimeline(),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (complaint != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ComplaintChatScreen(
                          complaintId: complaint!.id,
                          complaintTitle: complaint!.title,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No active complaint data loaded.')),
                    );
                  }
                },
                icon: const Icon(Icons.forum_rounded, size: 20),
                label: const Text('Live Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _blue,
                  side: const BorderSide(color: _blue, width: 2),
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UpdateTaskScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Update Status',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkStatusTimeline() {
    final stages = [
      {'label': 'Submitted',     'icon': Icons.flag_rounded,          'status': 'submitted',        'desc': 'Issue reported by citizen'},
      {'label': 'Under Review',  'icon': Icons.manage_search_rounded,  'status': 'under_review',     'desc': 'Being reviewed by authority'},
      {'label': 'Team Assigned', 'icon': Icons.engineering_rounded,    'status': 'team_assigned',    'desc': 'Field team dispatched'},
      {'label': 'Work Started',  'icon': Icons.construction_rounded,   'status': 'repair_started',   'desc': 'Repair work in progress'},
      {'label': 'Completed',     'icon': Icons.handyman_rounded,       'status': 'repair_completed', 'desc': 'Work completed on site'},
      {'label': 'Closed',        'icon': Icons.verified_rounded,       'status': 'verified_closed',  'desc': 'Verified and closed'},
    ];

    final statusOrder = ['submitted', 'under_review', 'team_assigned', 'repair_started', 'repair_completed', 'verified_closed'];
    final currentStatus = complaint?.status ?? 'submitted';
    final currentIndex = statusOrder.indexOf(currentStatus).clamp(0, 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('WORK STATUS',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.grey,
                    letterSpacing: 1.2)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Step ${currentIndex + 1}/6',
                style: const TextStyle(
                    color: _blue, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / stages.length,
            minHeight: 6,
            backgroundColor: Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(_blue),
          ),
        ),
        const SizedBox(height: 20),
        // Stages
        ...List.generate(stages.length, (i) {
          final stage = stages[i];
          final isDone    = i < currentIndex;
          final isCurrent = i == currentIndex;
          final isPending = i > currentIndex;
          final isLast    = i == stages.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon + connector
              Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? _blue
                          : isCurrent
                              ? _blue.withOpacity(0.12)
                              : Colors.grey.shade100,
                      border: Border.all(
                        color: isDone || isCurrent ? _blue : Colors.grey.shade200,
                        width: isCurrent ? 2 : 1.5,
                      ),
                    ),
                    child: Icon(
                      isDone ? Icons.check_rounded : stage['icon'] as IconData,
                      size: 18,
                      color: isDone
                          ? Colors.white
                          : isCurrent
                              ? _blue
                              : Colors.grey.shade300,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: isDone ? _blue.withOpacity(0.3) : Colors.grey.shade100,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Text
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage['label'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isPending ? Colors.grey.shade300 : _darkBlue,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stage['desc'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isPending ? Colors.grey.shade300 : Colors.grey.shade500,
                        ),
                      ),
                      // Timestamps
                      if (i == 0 && complaint?.createdAt != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 11, color: Colors.grey.shade400),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM yyyy • hh:mm a').format(complaint!.createdAt!),
                                style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        )
                      else if (isCurrent && complaint?.lastStatusUpdate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 11, color: _blue.withOpacity(0.7)),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM yyyy • hh:mm a').format(complaint!.lastStatusUpdate!),
                                style: TextStyle(fontSize: 10, color: _blue.withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                      // "Currently Here" badge
                      if (isCurrent)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Currently Here',
                            style: TextStyle(color: _blue, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _infoTable() {
    final taskId = complaint?.id ?? 'TASK-2025-000123';
    final reportedOn = complaint?.createdAt != null
        ? DateFormat('MMMM dd, yyyy hh:mm a').format(complaint!.createdAt!)
        : 'May 12, 2025 10:00 AM';
    final location = complaint?.location['address'] ?? 'NH-48, Delhi – Jaipur Highway\nNear KM 25, Rajasthan';
    final assignedTeam = complaint?.assignedTeamName ?? complaint?.assignedTeamId;

    final rows = [
      {'label': 'Task ID', 'value': taskId},
      {'label': 'Reported On', 'value': reportedOn},
      if (assignedTeam != null && assignedTeam.isNotEmpty)
        {'label': 'Assigned To', 'value': assignedTeam},
      {'label': 'Location', 'value': location},
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: rows.map((r) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(r['label']!,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13)),
                ),
                Expanded(
                  child: Text(r['value']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1A1A2E))),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
