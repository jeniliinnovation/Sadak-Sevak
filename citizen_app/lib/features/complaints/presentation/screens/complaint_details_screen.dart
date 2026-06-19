import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/complaint_model.dart';
import '../../domain/comment_model.dart';
import '../../data/complaint_repository.dart';
import '../../../contractor/data/contractor_repository.dart';
import 'complaint_chat_screen.dart';
import '../../../field_team/presentation/screens/update_task_screen.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final Complaint complaint;
  const ComplaintDetailsScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  final _complaintRepo = ComplaintRepository();
  final _contractorRepo = ContractorRepository();
  late Complaint _complaint;
  List<CommentModel> _comments = [];
  bool _isLoadingComments = true;
  bool _hasSupported = false;
  LatLng? _userLocation;
  double? _distanceInKm;
  String? _address;
  bool _isFetchingAddress = false;
  String _userRole = 'citizen';
  String _currentUserId = '';
  List<String> _submittedOfferIds = [];

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
    _loadUserRole();
    _loadComments();
    _determinePosition();
    _fetchAddress();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userRole = prefs.getString('user_role')?.toLowerCase() ?? 'citizen';
        _currentUserId = prefs.getString('user_id') ?? '';
        _submittedOfferIds = prefs.getStringList('contractor_submitted_offers') ?? [];
      });
    }
    if (_userRole == 'contractor') {
      _syncBidsFromDatabase();
    }
  }

  Future<void> _syncBidsFromDatabase() async {
    try {
      final bids = await _contractorRepo.getMyBids();
      if (bids.isNotEmpty) {
        final List<String> newOfferIds = [];
        final prefs = await SharedPreferences.getInstance();
        
        for (var bid in bids) {
          final String? complaintId = bid['complaintId']?.toString();
          if (complaintId != null) {
            newOfferIds.add(complaintId);
            
            // Cache cost, duration, message in SharedPreferences
            final cost = bid['cost']?.toString() ?? '';
            final duration = bid['duration']?.toString() ?? '';
            final message = bid['message']?.toString() ?? '';
            
            await prefs.setString('offer_cost_$complaintId', cost);
            await prefs.setString('offer_duration_$complaintId', duration);
            await prefs.setString('offer_message_$complaintId', message);
          }
        }
        
        await prefs.setStringList('contractor_submitted_offers', newOfferIds);
        if (mounted) {
          setState(() {
            _submittedOfferIds = newOfferIds;
          });
        }
      }
    } catch (e) {
      debugPrint('Error syncing bids from database: $e');
    }
  }

  bool _hasSubmittedOffer(String complaintId) {
    return _submittedOfferIds.contains(complaintId);
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
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
          setState(() {
            _userLocation = LatLng(pos.latitude, pos.longitude);
            _calculateDistance();
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _fetchAddress() async {
    final lat = _complaint.latitude;
    final lng = _complaint.longitude;

    if (lat == 0.0 && lng == 0.0) return;

    setState(() => _isFetchingAddress = true);
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          _address =
              '${p.street}, ${p.subLocality}, ${p.locality}, ${p.postalCode}';
          _isFetchingAddress = false;
        });
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      if (mounted) setState(() => _isFetchingAddress = false);
    }
  }

  void _calculateDistance() {
    if (_userLocation == null) return;
    final complaintLat = _complaint.latitude;
    final complaintLng = _complaint.longitude;

    final distance = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      complaintLat,
      complaintLng,
    );

    setState(() {
      _distanceInKm = distance / 1000;
    });
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _complaintRepo.getComments(_complaint.id);
      if (mounted) {
        setState(() {
          _comments = comments;
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingComments = false);
    }
  }

  Future<void> _openMaps() async {
    final lat = _complaint.latitude;
    final lng = _complaint.longitude;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complaint Detail',
          style: const TextStyle(
            color: AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share_outlined,
              color: AppTheme.secondaryColor,
              size: 20,
            ),
          ),
        ],
      ),
      body: _isFieldTeamUser() && _isComplaintAssigned()
          ? Stack(
              children: [
                _buildFieldAssignmentView(),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildFieldTeamActionButtons(),
                ),
              ],
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatusHeader(),
                      if (_userRole == 'contractor') _buildActiveOfferSection(),
                      FadeInUp(child: _buildMainInfo()),
                      FadeInUp(
                        delay: const Duration(milliseconds: 100),
                        child: _buildStatsRow(),
                      ),
                      const Divider(
                        height: 32,
                        thickness: 1,
                        indent: 24,
                        endIndent: 24,
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 130),
                        child: _buildWorkStatusTimeline(),
                      ),
                      const Divider(
                        height: 32,
                        thickness: 1,
                        indent: 24,
                        endIndent: 24,
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 150),
                        child: _buildDescriptionSection(),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildLocationSection(),
                      ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 250),
                        child: _buildPhotosSection(),
                      ),
                      if (_complaint.repairProof != null)
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: _buildRepairProofSection(),
                        ),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildCommentsSection(),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildActionButtons(),
                ),
              ],
            ),
    );
  }

  Widget _buildCommentsSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'COMMUNITY FEEDBACK',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              if (!_isLoadingComments)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_comments.length} Comments',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (_isLoadingComments)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (_comments.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 48,
                    color: Colors.grey.shade100,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No comments yet. Be the first to share!',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _comments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) =>
                  _buildCommentItem(_comments[index]),
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(CommentModel comment) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: Text(
            comment.userName[0].toUpperCase(),
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    comment.userName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM').format(comment.createdAt),
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Text(
                  comment.content,
                  style: const TextStyle(
                    color: AppTheme.secondaryColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHeader() {
    Color statusColor = AppTheme.getStatusColor(_complaint.status);
    String statusLabel;

    switch (_complaint.status) {
      case 'submitted':
        statusLabel = 'Reported';
        break;
      case 'under_review':
        statusLabel = 'Under Review';
        break;
      case 'team_assigned':
        statusLabel = 'Team Assigned';
        break;
      case 'repair_started':
        statusLabel = 'Work in Progress';
        break;
      case 'repair_completed':
        statusLabel = 'Repair Completed';
        break;
      case 'verified_closed':
        statusLabel = 'Verified';
        break;
      case 'reopened':
        statusLabel = 'Reopened';
        break;
      default:
        statusLabel = _complaint.status.replaceAll('_', ' ').toUpperCase();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      color: statusColor.withOpacity(0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Text(
            'Updated ${DateFormat('dd MMM').format(_complaint.lastStatusUpdate ?? _complaint.createdAt ?? DateTime.now())}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  bool _isFieldTeamUser() {
    final role = _userRole.toLowerCase();
    return role == 'team_member' ||
        role == 'field_team' ||
        role.contains('team');
  }

  bool _isComplaintAssigned() {
    return (_complaint.assignedTeamName?.isNotEmpty == true) ||
        (_complaint.assignedTeamId?.isNotEmpty == true);
  }

  Widget _buildFieldAssignmentView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusHeader(),
          const SizedBox(height: 20),
          FadeInUp(child: _buildAssignmentCard()),
          const SizedBox(height: 20),
          const Divider(height: 32, thickness: 1, indent: 24, endIndent: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _buildMainInfo(),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 150),
            child: _buildDescriptionSection(),
          ),
          const Divider(height: 32, thickness: 1, indent: 24, endIndent: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 175),
            child: _buildWorkStatusTimeline(),
          ),
          const Divider(height: 32, thickness: 1, indent: 24, endIndent: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildLocationSection(),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 250),
            child: _buildPhotosSection(),
          ),
          if (_complaint.repairProof != null)
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildRepairProofSection(),
            ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard() {
    final assignedTeam = _complaint.assignedTeamName?.isNotEmpty == true
        ? _complaint.assignedTeamName!
        : (_complaint.assignedTeamId ?? 'Unassigned');
    final updatedAt =
        _complaint.lastStatusUpdate ?? _complaint.createdAt ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assignment Details',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _complaint.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 18),
            _buildAssignmentInfoRow('Assigned Team', assignedTeam),
            const SizedBox(height: 12),
            _buildAssignmentInfoRow('Status', _getStatusLabel()),
            const SizedBox(height: 12),
            _buildAssignmentInfoRow(
              'Updated',
              DateFormat('dd MMM yyyy • hh:mm a').format(updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.secondaryColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusLabel() {
    switch (_complaint.status) {
      case 'submitted':
        return 'Reported';
      case 'under_review':
        return 'Under Review';
      case 'team_assigned':
        return 'Team Assigned';
      case 'repair_started':
        return 'Work in Progress';
      case 'repair_completed':
        return 'Repair Completed';
      case 'verified_closed':
        return 'Verified';
      case 'reopened':
        return 'Reopened';
      default:
        return _complaint.status.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _buildMainInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildBadge(_complaint.category, Colors.purple),
              const SizedBox(width: 8),
              _buildBadge(
                '${_complaint.priority} Priority',
                _getPriorityColor(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _complaint.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat(
                  'dd MMMM yyyy • hh:mm a',
                ).format(_complaint.createdAt ?? DateTime.now()),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (_complaint.priority) {
      case 'Critical':
        return Colors.red;
      case 'High':
        return Colors.deepOrange;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            Icons.thumb_up_rounded,
            '${_complaint.likesCount}',
            'Support',
            Colors.teal,
          ),
          _buildStatItem(
            Icons.verified_user_rounded,
            '${_complaint.confirmationCount}',
            'Confirmed',
            Colors.blue,
          ),
          _buildStatItem(
            Icons.chat_bubble_rounded,
            '${_comments.length}',
            'Comments',
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String val, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Text(
              val,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DESCRIPTION',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _complaint.description,
            style: const TextStyle(
              color: Color(0xFF455A64),
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final hasLocation = _complaint.hasLocation;
    final address = _isFetchingAddress
        ? 'Fetching address...'
        : (hasLocation
              ? (_address ??
                    _complaint.location['address'] ??
                    'No address found')
              : 'Location data unavailable');
    final lat = hasLocation ? _complaint.latitude : 0.0;
    final lng = hasLocation ? _complaint.longitude : 0.0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LOCATION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                  letterSpacing: 1.2,
                ),
              ),
              if (_distanceInKm != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_distanceInKm!.toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              TextButton.icon(
                onPressed: hasLocation ? _openMaps : null,
                icon: const Icon(
                  Icons.directions_rounded,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
                label: const Text(
                  'Directions',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 18,
                color: Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildMapCard(lat, lng, hasLocation: hasLocation),
        ],
      ),
    );
  }

  bool _mapInteractive = false;

  Widget _buildMapCard(double lat, double lng, {required bool hasLocation}) {
    if (!hasLocation) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200, width: 1),
          color: Colors.grey.shade50,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.location_off_outlined, size: 32, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                'No location data available',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final complaintPoint = LatLng(lat, lng);
    return Column(
      children: [
        Container(
          height: _mapInteractive ? 320 : 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _mapInteractive
                  ? AppTheme.primaryColor
                  : Colors.grey.shade100,
              width: _mapInteractive ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                FlutterMap(
                  options: MapOptions(
                    initialCenter: complaintPoint,
                    initialZoom: 14,
                    interactionOptions: InteractionOptions(
                      flags: _mapInteractive
                          ? InteractiveFlag.all
                          : InteractiveFlag.none,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.sadaksevak.citizen',
                    ),
                    MarkerLayer(
                      markers: [
                        if (_userLocation != null)
                          Marker(
                            point: _userLocation!,
                            child: Container(
                              width: 16,
                              height: 16,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Marker(
                          point: complaintPoint,
                          width: 80.0,
                          height: 50.0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Issue',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              CustomPaint(
                                size: const Size(12, 6),
                                painter: _TrianglePainter(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Tap to activate overlay
                if (!_mapInteractive)
                  GestureDetector(
                    onTap: () => setState(() => _mapInteractive = true),
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 16,
                                color: AppTheme.primaryColor,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Tap to interact',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                // Close/lock button when active
                if (_mapInteractive)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => _mapInteractive = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 13,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Done',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    final mediaList = _complaint.mediaList;
    if (mediaList.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ATTACHED IMAGES',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: mediaList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final url = mediaList[index]['url'] as String?;
                if (url == null) return const SizedBox.shrink();
                return _buildSmallPhotoCard(url);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPhotoCard(String url) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 20,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRepairProofSection() {
    final proof = _complaint.repairProof!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REPAIR PROOF',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.green,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildPhotoCard(proof['mediaUrl']),
          const SizedBox(height: 12),
          Text(
            proof['completionNotes'] ?? 'No notes provided.',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String url) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            color: Colors.grey.shade50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported_outlined,
                  size: 40,
                  color: Colors.grey.shade300,
                ),
                const Text(
                  'Image unavailable',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkStatusTimeline() {
    const primary = AppTheme.primaryColor;
    final stages = [
      {'label': 'Reported', 'icon': Icons.flag_rounded, 'status': 'submitted'},
      {
        'label': 'Under Review',
        'icon': Icons.manage_search_rounded,
        'status': 'under_review',
      },
      {
        'label': 'Team Assigned',
        'icon': Icons.engineering_rounded,
        'status': 'team_assigned',
      },
      {
        'label': 'Repair Started',
        'icon': Icons.construction_rounded,
        'status': 'repair_started',
      },
      {
        'label': 'Repair Completed',
        'icon': Icons.handyman_rounded,
        'status': 'repair_completed',
      },
      {
        'label': 'Verified',
        'icon': Icons.verified_rounded,
        'status': 'verified_closed',
      },
    ];

    final statusOrder = [
      'submitted',
      'under_review',
      'team_assigned',
      'repair_started',
      'repair_completed',
      'verified_closed',
    ];
    final currentIndex = statusOrder
        .indexOf(_complaint.status)
        .clamp(0, stages.length - 1);
    final currentStageTime =
        _complaint.lastStatusUpdate ?? _complaint.createdAt;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'STATUS HISTORY',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(stages.length, (i) {
            final stage = stages[i];
            final isDone = i < currentIndex;
            final isCurrent = i == currentIndex;
            final isLast = i == stages.length - 1;
            final subtitle = _getStageSubtitle(
              stage['status'] as String,
              i == 0,
              isDone,
              isCurrent,
              currentStageTime,
            );

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone || isCurrent
                            ? primary
                            : Colors.grey.shade200,
                      ),
                      child: Center(
                        child: Icon(
                          isDone ? Icons.check : Icons.circle,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 44,
                        margin: const EdgeInsets.only(top: 4),
                        color: isDone ? primary : Colors.grey.shade200,
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                stage['label'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: isDone || isCurrent
                                      ? AppTheme.secondaryColor
                                      : Colors.grey.shade400,
                                ),
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Current',
                                  style: TextStyle(
                                    color: primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDone || isCurrent
                                ? Colors.grey.shade600
                                : Colors.grey.shade300,
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
      ),
    );
  }

  String _getStageSubtitle(
    String status,
    bool isFirstStage,
    bool isDone,
    bool isCurrent,
    DateTime? currentStageTime,
  ) {
    if (isFirstStage) {
      return _complaint.createdAt != null
          ? DateFormat('dd MMM yyyy • hh:mm a').format(_complaint.createdAt!)
          : 'Reported';
    }

    if (isCurrent) {
      return currentStageTime != null
          ? DateFormat('dd MMM yyyy • hh:mm a').format(currentStageTime)
          : 'Ongoing';
    }

    return isDone ? 'Completed' : 'Pending';
  }

  void _showAddCommentModal() {
    final TextEditingController commentController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Comment',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: commentController,
              maxLines: 4,
              autofocus: true,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Share your thoughts or updates about this issue...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final content = commentController.text.trim();
                if (content.isEmpty) return;

                try {
                  await _complaintRepo.addComment(_complaint.id, content);
                  if (mounted) {
                    Navigator.pop(context);
                    _loadComments(); // Refresh comments list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment posted!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Login required to comment'),
                        backgroundColor: Colors.orange.shade800,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Post Comment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_userRole == 'contractor') {
      final hasOffer = _hasSubmittedOffer(_complaint.id);
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
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
                  ).then((_) => _loadComments());
                },
                icon: const Icon(Icons.forum_rounded, size: 20),
                label: const Text(
                  'Live Chat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: hasOffer
                  ? Container(
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Offer Submitted',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _showBidOfferSheet(context, _complaint.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Offer to Repair',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      );
    }

    final isCitizen = _userRole == 'citizen';
    final isOwner =
        _currentUserId.isNotEmpty && _complaint.citizenId == _currentUserId;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isCitizen || isOwner) ...[
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
                  ).then((_) => _loadComments());
                },
                icon: const Icon(Icons.forum_rounded, size: 18),
                label: const Text(
                  'Live Chat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            if (isCitizen) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showAddCommentModal,
                  icon: const Icon(
                    Icons.add_comment_rounded,
                    size: 18,
                    color: AppTheme.primaryColor,
                  ),
                  label: const Text(
                    'Comment',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () async {
                  if (_hasSupported) return;
                  try {
                    await _complaintRepo.likeComplaint(_complaint.id);
                    setState(() {
                      _complaint.likesCount++;
                      _hasSupported = true;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thanks for your support!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.teal,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You have already supported this!'),
                          backgroundColor: Colors.grey,
                        ),
                      );
                      setState(() => _hasSupported = true);
                    }
                  }
                },
                child: Container(
                  height: 56,
                  width: 56,
                  decoration: BoxDecoration(
                    color: _hasSupported
                        ? Colors.teal.withOpacity(0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _hasSupported
                        ? Icons.thumb_up_rounded
                        : Icons.thumb_up_outlined,
                    color: _hasSupported
                        ? Colors.teal
                        : AppTheme.secondaryColor,
                  ),
                ),
              ),
            ],
          ] else ...[
            // Citizen viewing someone else's complaint
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_hasSupported) return;
                  try {
                    await _complaintRepo.likeComplaint(_complaint.id);
                    setState(() {
                      _complaint.likesCount++;
                      _hasSupported = true;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thanks for your support!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.teal,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You have already supported this!'),
                          backgroundColor: Colors.grey,
                        ),
                      );
                      setState(() => _hasSupported = true);
                    }
                  }
                },
                icon: Icon(
                  _hasSupported
                      ? Icons.thumb_up_rounded
                      : Icons.thumb_up_outlined,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  _hasSupported ? 'Supported' : 'Support this Issue',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasSupported
                      ? Colors.teal
                      : AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFieldTeamActionButtons() {
    const blueColor = Color(0xFF4A80F0);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
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
                ).then((_) => _loadComments());
              },
              icon: const Icon(Icons.forum_rounded, size: 20),
              label: const Text(
                'Live Chat',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: blueColor,
                side: const BorderSide(color: blueColor, width: 2),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UpdateTaskScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Update Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOfferSection() {
    if (!_hasSubmittedOffer(_complaint.id)) return const SizedBox.shrink();

    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final prefs = snapshot.data!;
        final cost = prefs.getString('offer_cost_${_complaint.id}') ?? '';
        final duration = prefs.getString('offer_duration_${_complaint.id}') ?? '';
        final message = prefs.getString('offer_message_${_complaint.id}') ?? '';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.green.shade100, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green.shade700, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Your Active Offer',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade800, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Estimated Cost', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text('₹$cost', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Duration', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 2),
                          Text(duration, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (message.isNotEmpty) ...[
                  const Divider(height: 20),
                  const Text('Proposal Details', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(message, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBidOfferSheet(BuildContext context, String complaintId) {
    final costController = TextEditingController();
    final durationController = TextEditingController();
    final messageController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 40,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Submit Repair Offer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Provide your estimation to the department for repairing this road.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Estimated Cost (₹)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: costController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter estimated cost' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. 45000',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Estimated Duration',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: durationController,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter duration' : null,
                decoration: InputDecoration(
                  hintText: 'e.g. 5 Days',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'Repair Proposal & Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: messageController,
                maxLines: 3,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter proposal details' : null,
                decoration: InputDecoration(
                  hintText: 'Describe materials, methods, and quality standards...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  
                  final costStr = costController.text.trim();
                  final cost = double.tryParse(costStr) ?? 0.0;
                  final duration = durationController.text.trim();
                  final message = messageController.text.trim();

                  try {
                    // Save to remote MySQL database
                    await _contractorRepo.submitBid(complaintId, cost, duration, message);

                    // Sync/cache locally in SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    final currentOffers = prefs.getStringList('contractor_submitted_offers') ?? [];
                    if (!currentOffers.contains(complaintId)) {
                      currentOffers.add(complaintId);
                    }
                    await prefs.setStringList('contractor_submitted_offers', currentOffers);
                    await prefs.setString('offer_cost_$complaintId', costStr);
                    await prefs.setString('offer_duration_$complaintId', duration);
                    await prefs.setString('offer_message_$complaintId', message);

                    if (mounted) {
                      setState(() {
                        _submittedOfferIds = currentOffers;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Repair offer submitted successfully!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to submit offer: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'Submit Offer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final paint = ui.Paint()..color = color;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
