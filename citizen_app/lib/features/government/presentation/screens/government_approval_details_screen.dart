import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:sadak_sevak_citizen/features/government/domain/models/approval_model.dart';

class GovernmentApprovalDetailsScreen extends StatefulWidget {
  final ApprovalModel approval;

  const GovernmentApprovalDetailsScreen({super.key, required this.approval});

  @override
  State<GovernmentApprovalDetailsScreen> createState() => _GovernmentApprovalDetailsScreenState();
}

class _GovernmentApprovalDetailsScreenState extends State<GovernmentApprovalDetailsScreen> {
  static const _departments = [
    'Finance Department',
    'Infrastructure Planning',
    'Public Works Dept',
    'Urban Development',
    'Road Safety Authority',
    'City Council Board',
    'Emergency Funds Committee',
    'Environmental Clearances',
  ];

  String _assignedDepartment = 'Unassigned';
  String? _selectedDepartment;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
  }

  void _assignDepartment() async {
    if (_selectedDepartment == null || _selectedDepartment == _assignedDepartment) return;
    setState(() => _isAssigning = true);
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _assignedDepartment = _selectedDepartment!;
      _isAssigning = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 8),
              Text('$_assignedDepartment assigned successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF43A047),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Widget _buildStatusBanner() {
    Color statusColor;
    String statusLabel = widget.approval.status;

    switch (widget.approval.status.toLowerCase()) {
      case 'approved':
        statusColor = const Color(0xFF43A047);
        break;
      case 'rejected':
        statusColor = const Color(0xFFE53935);
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = const Color(0xFF78909C);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: statusColor.withOpacity(0.1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                'Current Status: $statusLabel',
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepartmentAssignmentSection() {
    const primaryOrange = Color(0xFFF4511E);
    final bool hasChanged = _selectedDepartment != null && _selectedDepartment != _assignedDepartment;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DEPARTMENT ASSIGNMENT',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),

          // Currently Assigned Department Card
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
                  child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 24),
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
                        _assignedDepartment,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _assignedDepartment == 'Unassigned' ? Icons.warning_rounded : Icons.verified_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Reassign Dropdown
          const Text(
            'Assign or reassign department:',
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
                  child: Text('Select a department...', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
                value: _selectedDepartment,
                icon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
                ),
                borderRadius: BorderRadius.circular(14),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                items: _departments.map((dept) {
                  final isAssigned = dept == _assignedDepartment;
                  return DropdownMenuItem(
                    value: dept,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            dept,
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
                onChanged: (val) => setState(() => _selectedDepartment = val),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Assign Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: hasChanged && !_isAssigning ? _assignDepartment : null,
              icon: _isAssigning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.assignment_ind_rounded),
              label: Text(
                _isAssigning ? 'Assigning...' : 'Assign Department',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);

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
          'Approval Details',
          style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBanner(),
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
                            widget.approval.id,
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
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${widget.approval.priority} Priority',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.approval.title,
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
                          widget.approval.date,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Text(
                          widget.approval.zone,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_rounded, size: 16, color: Colors.grey.shade400),
                        const SizedBox(width: 8),
                        Text(
                          'Requested by: ${widget.approval.requestedBy}',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, indent: 24, endIndent: 24),
            
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: _buildDepartmentAssignmentSection(),
            ),

            const Divider(height: 1, thickness: 1, indent: 24, endIndent: 24),
            
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTIMATED COST',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.approval.cost,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'DESCRIPTION',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No additional details available for this approval currently. This is a generic description mock.',
                      style: TextStyle(color: Color(0xFF455A64), height: 1.6, fontSize: 15),
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
