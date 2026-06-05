import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../features/complaints/data/complaint_repository.dart';
import '../../../../features/complaints/domain/complaint_model.dart';
import '../../../../features/complaints/presentation/screens/complaint_details_screen.dart';

class MapScreen extends StatefulWidget {
  final String? initialCategory;
  const MapScreen({super.key, this.initialCategory});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final _complaintRepo = ComplaintRepository();
  late String _selectedCategory;
  Complaint? _selectedIssue;
  List<Complaint> _allComplaints = [];
  LatLng? _userLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'All';
    _loadData();
  }

  Future<void> _loadData() async {
    await _determinePosition();
    await _fetchComplaints();
  }

  Future<void> _determinePosition() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _userLocation = LatLng(pos.latitude, pos.longitude);
            _mapController.move(_userLocation!, 15);
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _fetchComplaints() async {
    try {
      final complaints = await _complaintRepo.getAllComplaints();
      if (mounted) {
        setState(() {
          _allComplaints = complaints;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Complaint> get _filteredComplaints {
    if (_selectedCategory == 'All') return _allComplaints;
    
    if (_selectedCategory == 'Nearby') {
      if (_userLocation == null) return _allComplaints;
      return _allComplaints.where((c) {
        final dist = Geolocator.distanceBetween(
          _userLocation!.latitude,
          _userLocation!.longitude,
          c.location['lat'] as double? ?? 0.0,
          c.location['lng'] as double? ?? 0.0,
        );
        return dist <= 5000; // 5km radius
      }).toList();
    }

    String catVal = _selectedCategory.toLowerCase();
    if (catVal == 'potholes') return _allComplaints.where((c) => c.category.toLowerCase().contains('pothole')).toList();
    if (catVal == 'lights') return _allComplaints.where((c) => c.category.toLowerCase().contains('light')).toList();
    if (catVal == 'cleanup') return _allComplaints.where((c) => c.category.toLowerCase().contains('trash') || c.category.toLowerCase().contains('clean')).toList();
    return _allComplaints;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(22.3039, 70.8022),
              initialZoom: 13.5,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sadaksevak.citizen',
              ),
              MarkerLayer(
                markers: [
                  // User Location Marker
                  if (_userLocation != null)
                    Marker(
                      point: _userLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
                        child: Container(decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                      ),
                    ),
                  // Complaint Markers
                  ..._filteredComplaints.map((issue) {
                    bool isSelected = _selectedIssue?.id == issue.id;
                    Color markerColor = _getMarkerColor(issue.status);
                    final lat = issue.location['lat'] as double? ?? 0.0;
                    final lng = issue.location['lng'] as double? ?? 0.0;
                    
                    return Marker(
                      point: LatLng(lat, lng),
                      width: 60,
                      height: 60,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedIssue = isSelected ? null : issue),
                        child: Pulse(
                          infinite: !isSelected,
                          child: Container(
                            padding: EdgeInsets.all(isSelected ? 6 : 4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                            child: Icon(
                              isSelected ? Icons.location_history_rounded : Icons.location_on_rounded,
                              color: markerColor,
                              size: isSelected ? 30 : 25,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ],
          ),

          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                _buildCategoryChips(),
              ],
            ),
          ),

          if (_selectedIssue != null)
            Positioned(
              bottom: 110,
              left: 20,
              right: 20,
              child: FadeInUp(duration: const Duration(milliseconds: 300), child: _buildIssueDetailsCard()),
            ),

          Positioned(
            right: 20,
            bottom: (_selectedIssue != null) ? 310 : 110,
            child: _buildMapActionBtn(Icons.my_location_rounded, () {
              if (_userLocation != null) _mapController.move(_userLocation!, 15);
            }, isPrimary: true),
          ),
          
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
        ],
      ),
    );
  }

  Color _getMarkerColor(String status) {
    return AppTheme.getStatusColor(status);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 55,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: Row(
          children: const [
            SizedBox(width: 15),
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 10),
            Expanded(child: Text('Search road issues...', style: TextStyle(color: Colors.grey))),
            Icon(Icons.tune_rounded, color: AppTheme.primaryColor),
            SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['All', 'Nearby', 'Potholes', 'Lights', 'Cleanup'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: categories.map((cat) {
          bool isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat),
              selectedColor: AppTheme.primaryColor,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
              backgroundColor: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIssueDetailsCard() {
    final image = _selectedIssue!.mediaList.isNotEmpty ? _selectedIssue!.mediaList[0]['url'] : null;
    
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20)]),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                height: 60, width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                  image: image != null ? DecorationImage(image: NetworkImage(image), fit: BoxFit.cover) : null,
                ),
                child: image == null ? const Icon(Icons.image_not_supported_outlined, color: Colors.grey) : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedIssue!.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('#${_selectedIssue!.id.length > 8 ? _selectedIssue!.id.substring(0, 8).toUpperCase() : _selectedIssue!.id.toUpperCase()} • ${_selectedIssue!.category}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(Icons.warning_amber_rounded, color: _getMarkerColor(_selectedIssue!.status)),
                  Text(_selectedIssue!.status.replaceAll('_', ' ').toUpperCase(), style: TextStyle(color: _getMarkerColor(_selectedIssue!.status), fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => ComplaintDetailsScreen(complaint: _selectedIssue!))),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: const Text('View Full Report', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapActionBtn(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return FloatingActionButton.small(
      onPressed: onTap,
      backgroundColor: isPrimary ? AppTheme.primaryColor : Colors.white,
      child: Icon(icon, color: isPrimary ? Colors.white : Colors.grey),
    );
  }
}
