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
    // Centering is already handled by initialCenter in MapOptions
    await _fetchComplaints();
    await _determinePosition(); // This will move to user location IF permission is granted
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        Position pos;
        try {
          pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 4),
          );
        } catch (_) {
          // Fallback to low accuracy if high accuracy times out/fails on Web
          pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 4),
          );
        }
        if (mounted) {
          final userLoc = LatLng(pos.latitude, pos.longitude);
          setState(() {
            _userLocation = userLoc;
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _mapController.move(userLoc, 15);
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting position on map: $e');
    }
  }

  Future<void> _fetchComplaints() async {
    try {
      final complaints = await _complaintRepo.getAllComplaints();
      debugPrint('Map loaded ${complaints.length} complaints');
      if (mounted) {
        setState(() {
          _allComplaints = complaints;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Map fetch error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Complaint> get _filteredComplaints {
    List<Complaint> filtered = _allComplaints;
    if (_selectedCategory == 'Nearby') {
      if (_userLocation != null) {
        filtered = _allComplaints.where((c) {
          final lat = c.latitude;
          final lng = c.longitude;
          final dist = Geolocator.distanceBetween(
            _userLocation!.latitude,
            _userLocation!.longitude,
            lat,
            lng,
          );
          return dist <= 5000;
        }).toList();
      } else {
        filtered = [];
      }
    } else if (_selectedCategory != 'All') {
      String catVal = _selectedCategory.toLowerCase();
      if (catVal == 'potholes') filtered = _allComplaints.where((c) => c.category.toLowerCase().contains('pothole')).toList();
      else if (catVal == 'lights') filtered = _allComplaints.where((c) => c.category.toLowerCase().contains('light')).toList();
      else if (catVal == 'cleanup') filtered = _allComplaints.where((c) => c.category.toLowerCase().contains('trash') || c.category.toLowerCase().contains('clean')).toList();
    }

    // Filter out items with 0,0 location
    return filtered.where((c) {
      final lat = (c.location['lat'] as num?)?.toDouble() ?? 0.0;
      final lng = (c.location['lng'] as num?)?.toDouble() ?? 0.0;
      return lat != 0.0 && lng != 0.0;
    }).toList();
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
                    final lat = issue.latitude;
                    final lng = issue.longitude;
                    
                    return Marker(
                      point: LatLng(lat, lng),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedIssue = isSelected ? null : issue),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? markerColor.withOpacity(0.2) : Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                            border: Border.all(color: markerColor, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: markerColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                          child: Icon(
                            isSelected ? Icons.location_history_rounded : Icons.location_on_rounded,
                            color: markerColor,
                            size: 28,
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

          if (!_isLoading && _filteredComplaints.isEmpty)
            Positioned.fill(child: _buildEmptyLocationFallback()),

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

  Widget _buildEmptyLocationFallback() {
    String message;
    if (_allComplaints.isEmpty) {
      message = 'No complaints available to show on the map.';
    } else if (_selectedCategory == 'Nearby' && _userLocation == null) {
      message = 'Grant location permission to show nearby complaints.';
    } else {
      message = 'No complaints with valid location data are available.';
    }

    return Container(
      color: Colors.white.withOpacity(0.85),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off_outlined, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          if (_selectedCategory == 'Nearby' && _userLocation == null)
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Please enable location services and refresh the screen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDebugOverlay() {
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
          child: Text(
            'Debug: ${_allComplaints.length} loaded, ${_filteredComplaints.length} visible. Cat: $_selectedCategory',
            style: const TextStyle(color: Colors.white, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
