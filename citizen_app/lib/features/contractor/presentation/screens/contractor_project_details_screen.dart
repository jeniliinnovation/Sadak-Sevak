import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'contractor_update_progress_screen.dart';
import 'contractor_upload_photos_screen.dart';
import 'contractor_work_completion_screen.dart';
import 'contractor_inspection_status_screen.dart';

class ContractorProjectDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> project;

  const ContractorProjectDetailsScreen({
    super.key,
    required this.project,
  });

  @override
  State<ContractorProjectDetailsScreen> createState() => _ContractorProjectDetailsScreenState();
}

class _ContractorProjectDetailsScreenState extends State<ContractorProjectDetailsScreen> {
  late Map<String, dynamic> _project;

  @override
  void initState() {
    super.initState();
    _project = Map<String, dynamic>.from(widget.project);
  }

  void _showLocationDialog() {
    final isDark = false;
    
    final latVal = (_project['latitude'] is num)
        ? (_project['latitude'] as num).toDouble()
        : double.tryParse(_project['latitude']?.toString() ?? '') ?? 22.3039;
    final lngVal = (_project['longitude'] is num)
        ? (_project['longitude'] as num).toDouble()
        : double.tryParse(_project['longitude']?.toString() ?? '') ?? 70.8022;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Project Location',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Road: ${_project['roadName']}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Location: ${_project['location']}',
                style: TextStyle(
                  color: isDark ? Colors.grey.shade300 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(latVal, lngVal),
                      initialZoom: 15.0,
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.sadaksevak.citizen',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(latVal, lngVal),
                            width: 45,
                            height: 45,
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E2E2E) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.map_outlined, color: isDark ? Colors.grey.shade400 : Colors.grey),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lat: $latVal',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey),
                        ),
                        Text(
                          'Lng: $lngVal',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = false;

    final statusColor = _project['status'] == 'Completed'
        ? (isDark ? Colors.green.shade400 : const Color(0xFF2E7D32))
        : _project['status'] == 'In Progress'
            ? (isDark ? Colors.orange.shade400 : const Color(0xFFF57C00))
            : (isDark ? Colors.blue.shade400 : const Color(0xFF1976D2));
    final statusBgColor = _project['status'] == 'Completed'
        ? (isDark ? Colors.green.shade900.withOpacity(0.3) : const Color(0xFFE8F5E9))
        : _project['status'] == 'In Progress'
            ? (isDark ? Colors.orange.shade900.withOpacity(0.3) : const Color(0xFFFFF4E5))
            : (isDark ? Colors.blue.shade900.withOpacity(0.3) : const Color(0xFFE3F2FD));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Project Details',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _project['title']!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Project ID: ${_project['id']}',
                        style: TextStyle(
                          color: isDark ? Colors.grey.shade400 : Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    _project['status']!,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Progress Bar
            if (_project['status'] != 'Assigned') ...[
              _buildSectionTitle('Progress Status'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_project['progress']}% Completed',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const Icon(Icons.trending_up, color: AppTheme.primaryColor),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _project['progress'] / 100.0,
                        minHeight: 8,
                        backgroundColor: isDark ? const Color(0xFF2E2E2E) : Colors.grey.shade100,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Project Info Details Grid
            _buildSectionTitle('Project Specifications'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.add_road, 'Road Name', _project['roadName']!),
                  Divider(height: 28, color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                  _buildInfoRow(Icons.location_on_outlined, 'Location', _project['location']!),
                  Divider(height: 28, color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                  _buildInfoRow(Icons.calendar_today_outlined, 'Assigned Date', _project['assignedDate']!),
                  Divider(height: 28, color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                  _buildInfoRow(Icons.alarm_on, 'Due Date', _project['dueDate']!),
                  Divider(height: 28, color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                  _buildInfoRow(
                    Icons.priority_high,
                    'Priority',
                    _project['priority']!,
                    valColor: _project['priority'] == 'High' ? Colors.red.shade400 : (isDark ? Colors.white : Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description
            _buildSectionTitle('Work Scope & Description'),
            const SizedBox(height: 10),
            Text(
              _project['description']!,
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Assigned Officer
            _buildSectionTitle('Supervising Officer'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _project['officerName']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _project['officerContact']!,
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.phone, color: AppTheme.primaryColor),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions list
            _buildSectionTitle('Contractor Actions'),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _buildActionCard(
                  icon: Icons.edit_road_outlined,
                  label: _project['status'] == 'Assigned' ? 'Start Work' : 'Update Progress',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContractorUpdateProgressScreen(
                          project: _project,
                          onUpdate: (progress, status) {
                            setState(() {
                              _project['progress'] = progress;
                              _project['status'] = status;
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.camera_alt_outlined,
                  label: 'Upload Photos',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContractorUploadPhotosScreen(project: _project),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.assignment_turned_in_outlined,
                  label: 'Work Completion',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContractorWorkCompletionScreen(
                          project: _project,
                          onComplete: () {
                            setState(() {
                              _project['progress'] = 100;
                              _project['status'] = 'Completed';
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
                _buildActionCard(
                  icon: Icons.timeline_outlined,
                  label: 'Inspection Status',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContractorInspectionStatusScreen(project: _project),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // View Location Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _showLocationDialog,
                icon: const Icon(Icons.map_rounded, color: Colors.white),
                label: const Text('View Location', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final isDark = false;
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppTheme.secondaryColor,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? valColor}) {
    final isDark = false;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade400 : Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: valColor ?? (isDark ? Colors.white : AppTheme.secondaryColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = false;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
      ),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? Colors.white.withOpacity(0.9) : AppTheme.secondaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
