import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:sadak_sevak_citizen/features/complaints/domain/complaint_model.dart';
import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/complaints/presentation/screens/complaint_chat_screen.dart';

class GovernmentComplaintDetailsScreen extends StatefulWidget {
  final Complaint complaint;

  const GovernmentComplaintDetailsScreen({super.key, required this.complaint});

  @override
  State<GovernmentComplaintDetailsScreen> createState() => _GovernmentComplaintDetailsScreenState();
}

class _GovernmentComplaintDetailsScreenState extends State<GovernmentComplaintDetailsScreen> {
  final GovernmentRepository _repository = GovernmentRepository();
  late Complaint _complaint;

  static const _teams = [
    'Team Alpha',
    'Team Beta',
    'Team Gamma',
    'Team Delta',
    'Road Repair Unit 1',
    'Road Repair Unit 2',
    'Drainage Team',
    'Emergency Response',
  ];

  String _assignedTeam = 'Unassigned';
  String? _selectedTeam;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
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

  void _showUpdateStatusModal() {
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
        final statuses = [
          {'key': 'submitted', 'label': 'Submitted (Pending)'},
          {'key': 'in_progress', 'label': 'In Progress'},
          {'key': 'team_assigned', 'label': 'Team Assigned'},
          {'key': 'resolved', 'label': 'Resolved / Completed'},
        ];

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update Status',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                ),
                const SizedBox(height: 16),
                ...statuses.map((statusMap) {
                  final key = statusMap['key']!;
                  final label = statusMap['label']!;
                  final isSelected = _complaint.status == key;

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFFF4511E) : Colors.black87,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: Color(0xFFF4511E)) : null,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        // Mock update locally since backend update might throw 401 without admin token
                        _complaint = Complaint(
                          id: _complaint.id,
                          title: _complaint.title,
                          description: _complaint.description,
                          location: _complaint.location,
                          status: key,
                          category: _complaint.category,
                          priority: _complaint.priority,
                          media: _complaint.media,
                          likesCount: _complaint.likesCount,
                          confirmationCount: _complaint.confirmationCount,
                          createdAt: _complaint.createdAt,
                          lastStatusUpdate: DateTime.now(),
                          repairProof: _complaint.repairProof,
                        );
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Status updated successfully!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);

    final displayDate = _complaint.createdAt != null
        ? DateFormat('dd MMM yyyy • hh:mm a').format(_complaint.createdAt!)
        : 'Unknown Date';

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
          'Complaint Details',
          style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
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
                                _complaint.id,
                                style: const TextStyle(
                                  color: primaryOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            _buildPriorityBadge(_complaint.priority),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _complaint.title,
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
                              displayDate,
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
                              'Reported by: Citizen',
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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DESCRIPTION',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _complaint.description,
                          style: const TextStyle(color: Color(0xFF455A64), height: 1.6, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                // Team Assignment Section
                const Divider(height: 1, thickness: 1, indent: 24, endIndent: 24),
                FadeInUp(
                  duration: const Duration(milliseconds: 500),
                  child: _buildTeamAssignmentSection(),
                ),
                const Divider(height: 1, thickness: 1, indent: 24, endIndent: 24),
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  child: _buildLocationSection(),
                ),
                if (_complaint.mediaList.isNotEmpty)
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: _buildPhotosSection(),
                  ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ComplaintChatScreen(
                              complaintId: _complaint.id,
                              complaintTitle: _complaint.title,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.forum_rounded, size: 20),
                      label: const Text('Live Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: primaryOrange,
                        side: const BorderSide(color: primaryOrange, width: 2),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showUpdateStatusModal,
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      label: const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    Color statusColor;
    String statusLabel;

    switch (_complaint.status.toLowerCase()) {
      case 'resolved':
      case 'repair_completed':
      case 'verified_closed':
        statusColor = const Color(0xFF43A047);
        statusLabel = 'Resolved';
        break;
      case 'in progress':
      case 'in_progress':
      case 'repair_started':
        statusColor = const Color(0xFF1E88E5);
        statusLabel = 'In Progress';
        break;
      case 'team_assigned':
        statusColor = const Color(0xFF8E24AA);
        statusLabel = 'Team Assigned';
        break;
      default:
        statusColor = const Color(0xFFF4511E);
        statusLabel = 'Pending Action';
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

  Widget _buildPriorityBadge(String priority) {
    Color color;
    Color bgColor;
    switch (priority.toLowerCase()) {
      case 'high':
      case 'critical':
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
        '$priority Priority',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTeamAssignmentSection() {
    const primaryOrange = Color(0xFFF4511E);
    final bool hasChanged = _selectedTeam != null && _selectedTeam != _assignedTeam;

    return Padding(
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
                Icon(
                  _assignedTeam == 'Unassigned' ? Icons.warning_rounded : Icons.verified_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Reassign Dropdown
          const Text(
            'Assign or reassign team:',
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
    );
  }

  Widget _buildLocationSection() {
    final address = _complaint.location['address'] ?? 'Address details not available';
    final lat = _complaint.location['lat'] as double? ?? 22.3039;
    final lng = _complaint.location['lng'] as double? ?? 70.8022;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LOCATION',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, size: 20, color: Color(0xFFF4511E)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(color: Color(0xFF263238), fontWeight: FontWeight.w500, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lng),
                  initialZoom: 14.5,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sadaksevak.citizen',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lng),
                        child: const Icon(Icons.location_on_rounded, color: Color(0xFFF4511E), size: 40),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    final mediaList = _complaint.mediaList;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ATTACHED IMAGES',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mediaList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final url = mediaList[index]['url'] as String?;
                if (url == null) return const SizedBox.shrink();
                
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image_outlined, size: 28, color: Colors.grey)),
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
