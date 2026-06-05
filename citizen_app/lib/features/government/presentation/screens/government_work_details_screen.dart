import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sadak_sevak_citizen/features/government/domain/models/work_task_model.dart';

class GovernmentWorkDetailsScreen extends StatefulWidget {
  final WorkTaskModel task;

  const GovernmentWorkDetailsScreen({super.key, required this.task});

  @override
  State<GovernmentWorkDetailsScreen> createState() => _GovernmentWorkDetailsScreenState();
}

class _GovernmentWorkDetailsScreenState extends State<GovernmentWorkDetailsScreen> {
  static const _teams = [
    'Team Alpha',
    'Team Beta',
    'Team Gamma',
    'Team Delta',
    'Team Epsilon',
    'Road Repair Unit 1',
    'Road Repair Unit 2',
    'Infrastructure Squad',
    'Drainage Team',
    'Emergency Response',
  ];

  late String _assignedTeam;
  String? _selectedTeam;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _assignedTeam = widget.task.team;
    _selectedTeam = _teams.contains(widget.task.team) ? widget.task.team : null;
  }

  void _assignTeam() async {
    if (_selectedTeam == null || _selectedTeam == _assignedTeam) return;
    setState(() => _isAssigning = true);
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _assignedTeam = _selectedTeam!;
      _isAssigning = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('$_assignedTeam assigned successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Color get _statusColor {
    switch (widget.task.status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF43A047);
      case 'in progress':
      case 'in_progress':
        return const Color(0xFF1E88E5);
      case 'assigned':
        return const Color(0xFF8E24AA);
      case 'on hold':
        return Colors.orange;
      default:
        return const Color(0xFF78909C);
    }
  }

  Widget _buildStatusBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: _statusColor.withOpacity(0.1),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            'Status: ${widget.task.status}',
            style: TextStyle(color: _statusColor, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);
    final bool hasChanged = _selectedTeam != null && _selectedTeam != _assignedTeam;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryOrange, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Work Details',
          style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBanner(),

            // Header Info
            FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.task.id,
                            style: const TextStyle(
                              color: primaryOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${widget.task.progress}% Complete',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.task.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF263238),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Text(
                          widget.task.date,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Text(
                          widget.task.location,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 1, thickness: 1, indent: 24, endIndent: 24),

            // Progress Section
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROGRESS',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: widget.task.progress / 100.0,
                      backgroundColor: Colors.grey.shade200,
                      color: primaryOrange,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${widget.task.progress}%',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: primaryOrange),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Divider(height: 1, thickness: 1, indent: 24, endIndent: 24),

            // Team Assignment Section
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TEAM ASSIGNMENT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 16),

                    // Currently Assigned Team Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF4511E), Color(0xFFD84315)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF4511E).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.engineering_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Currently Assigned',
                                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _assignedTeam,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.verified_rounded, color: Colors.white70, size: 20),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Reassign Dropdown
                    const Text(
                      'Reassign to a different team:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF455A64)),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasChanged ? primaryOrange : Colors.grey.shade200,
                          width: hasChanged ? 1.5 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Color(0xFF263238), fontSize: 14),
                          hint: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text('Select a team...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                          ),
                          value: _selectedTeam,
                          icon: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                          ),
                          borderRadius: BorderRadius.circular(14),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          items: _teams.map((team) {
                            final isAssigned = team == _assignedTeam;
                            return DropdownMenuItem(
                              value: team,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      team,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isAssigned ? FontWeight.bold : FontWeight.normal,
                                        color: isAssigned ? primaryOrange : const Color(0xFF263238),
                                      ),
                                    ),
                                  ),
                                  if (isAssigned)
                                    const Icon(Icons.check_circle_rounded, color: primaryOrange, size: 16),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedTeam = val),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Assign Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: hasChanged && !_isAssigning ? _assignTeam : null,
                        icon: _isAssigning
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.assignment_ind_rounded),
                        label: Text(
                          _isAssigning ? 'Assigning...' : 'Assign Team',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade200,
                          disabledForegroundColor: Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: hasChanged ? 4 : 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
