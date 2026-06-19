import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:animate_do/animate_do.dart';

import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/government/domain/models/field_operation_model.dart';

class GovernmentFieldOperationsScreen extends StatefulWidget {
  const GovernmentFieldOperationsScreen({super.key});

  @override
  State<GovernmentFieldOperationsScreen> createState() => _GovernmentFieldOperationsScreenState();
}

class _GovernmentFieldOperationsScreenState extends State<GovernmentFieldOperationsScreen> {
  final MapController _mapController = MapController();
  final GovernmentRepository _repository = GovernmentRepository();

  bool _isLoading = true;
  List<FieldOperationModel> _activities = [];
  List<LatLng> _teamLocations = [];

  @override
  void initState() {
    super.initState();
    _fetchOperations();
  }

  Future<void> _fetchOperations() async {
    try {
      final operations = await _repository.getFieldOperations();
      setState(() {
        _activities = operations;
        _teamLocations = operations
            .where((op) => op.coordinates != null)
            .map((op) => op.coordinates!)
            .toList();
        if (_teamLocations.isEmpty) {
          _teamLocations.add(const LatLng(22.3039, 70.8022));
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);
    const darkOrange = Color(0xFFD84315);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Field Operations',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Orange Gradient Header
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white30, width: 1.5),
                        ),
                        child: const Icon(Icons.map_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Field Operations',
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
                    '${_activities.length} active operations',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatChip('Active Teams', '${_teamLocations.length}', Icons.groups_rounded),
                      _buildStatChip('On Duty', '${_activities.length}', Icons.work_rounded),
                      _buildStatChip('In Field', '${_activities.where((a) => a.type == 'inspection').length}', Icons.explore_rounded),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Map view
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: primaryOrange))
                : Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _teamLocations.isNotEmpty ? _teamLocations.first : const LatLng(22.3039, 70.8022),
                          initialZoom: 13.5,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.sadaksevak.citizen',
                          ),
                          MarkerLayer(
                            markers: [
                              for (int i = 0; i < _teamLocations.length; i++)
                                Marker(
                                  point: _teamLocations[i],
                                  width: 50,
                                  height: 50,
                                  child: Pulse(
                                    infinite: true,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: primaryOrange.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.group_work_rounded,
                                        color: primaryOrange,
                                        size: 26,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: FloatingActionButton.small(
                          onPressed: () {
                            if (_teamLocations.isNotEmpty) {
                              _mapController.move(_teamLocations.first, 13.5);
                            }
                          },
                          backgroundColor: Colors.white,
                          child: const Icon(Icons.my_location, color: primaryOrange),
                        ),
                      ),
                    ],
                  ),
          ),

          // Recent Field Activities
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Recent Field Activities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 12),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  Column(
                    children: _activities.map((activity) => _buildActivityRow(activity)).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
              ),
              Text(
                label,
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 9, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(FieldOperationModel activity) {
    IconData icon;
    Color iconColor;
    switch (activity.type) {
      case 'inspection':
        icon = Icons.search_rounded;
        iconColor = Colors.blue;
        break;
      case 'clearing':
        icon = Icons.cleaning_services_rounded;
        iconColor = Colors.teal;
        break;
      default:
        icon = Icons.build_rounded;
        iconColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF263238)),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      activity.location,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    activity.team,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity.time,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey.shade300),
            ],
          ),
        ],
      ),
    );
  }
}
