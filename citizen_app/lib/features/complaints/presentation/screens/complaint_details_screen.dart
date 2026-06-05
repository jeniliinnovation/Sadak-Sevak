import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';
import 'package:animate_do/animate_do.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/complaint_model.dart';
import '../../domain/comment_model.dart';
import '../../data/complaint_repository.dart';
import 'complaint_chat_screen.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final Complaint complaint;
  const ComplaintDetailsScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  final _complaintRepo = ComplaintRepository();
  late Complaint _complaint;
  List<CommentModel> _comments = [];
  bool _isLoadingComments = true;
  bool _hasSupported = false;
  LatLng? _userLocation;
  double? _distanceInKm;

  @override
  void initState() {
    super.initState();
    _complaint = widget.complaint;
    _loadComments();
    _determinePosition();
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
            _calculateDistance();
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _calculateDistance() {
    if (_userLocation == null) return;
    final complaintLat = _complaint.location['lat'] as double? ?? 0.0;
    final complaintLng = _complaint.location['lng'] as double? ?? 0.0;
    
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
    final lat = _complaint.location['lat'];
    final lng = _complaint.location['lng'];
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.secondaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Complaint Detail',
          style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share_outlined, color: AppTheme.secondaryColor, size: 20),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(),
                FadeInUp(child: _buildMainInfo()),
                FadeInUp(delay: const Duration(milliseconds: 100), child: _buildStatsRow()),
                const Divider(height: 48, thickness: 1, indent: 24, endIndent: 24),
                FadeInUp(delay: const Duration(milliseconds: 150), child: _buildDescriptionSection()),
                FadeInUp(delay: const Duration(milliseconds: 200), child: _buildLocationSection()),
                FadeInUp(delay: const Duration(milliseconds: 250), child: _buildPhotosSection()),
                if (_complaint.repairProof != null)
                   FadeInUp(delay: const Duration(milliseconds: 300), child: _buildRepairProofSection()),
                FadeInUp(delay: const Duration(milliseconds: 350), child: _buildTimelineSection()),
                FadeInUp(delay: const Duration(milliseconds: 400), child: _buildCommentsSection()),
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
              const Text('COMMUNITY FEEDBACK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, letterSpacing: 1.2)),
              if (!_isLoadingComments)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${_comments.length} Comments', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 11)),
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
                  Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Colors.grey.shade100),
                  const SizedBox(height: 12),
                  const Text('No comments yet. Be the first to share!', style: TextStyle(color: Colors.grey, fontSize: 13)),
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
              itemBuilder: (context, index) => _buildCommentItem(_comments[index]),
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
          child: Text(comment.userName[0].toUpperCase(), style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(comment.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondaryColor)),
                  Text(DateFormat('dd MMM').format(comment.createdAt), style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16), bottomLeft: Radius.circular(16)), border: Border.all(color: Colors.grey.shade100)),
                child: Text(comment.content, style: const TextStyle(color: AppTheme.secondaryColor, fontSize: 14, height: 1.4)),
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
      case 'submitted': statusLabel = 'Submitted'; break;
      case 'under_review': statusLabel = 'Under Review'; break;
      case 'team_assigned': statusLabel = 'Team Assigned'; break;
      case 'repair_started': statusLabel = 'Repair in Progress'; break;
      case 'repair_completed': statusLabel = 'Repair Completed'; break;
      case 'verified_closed': statusLabel = 'Verified & Closed'; break;
      case 'reopened': statusLabel = 'Reopened'; break;
      default: statusLabel = _complaint.status.replaceAll('_', ' ').toUpperCase();
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
              Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13)),
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
              _buildBadge('${_complaint.priority} Priority', _getPriorityColor()),
            ],
          ),
          const SizedBox(height: 16),
          Text(_complaint.title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade400),
              const SizedBox(width: 8),
              Text(DateFormat('dd MMMM yyyy • hh:mm a').format(_complaint.createdAt ?? DateTime.now()), style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
    );
  }

  Color _getPriorityColor() {
    switch (_complaint.priority) {
      case 'Critical': return Colors.red;
      case 'High': return Colors.deepOrange;
      case 'Medium': return Colors.orange;
      default: return Colors.green;
    }
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(Icons.thumb_up_rounded, '${_complaint.likesCount}', 'Support', Colors.teal),
          _buildStatItem(Icons.verified_user_rounded, '${_complaint.confirmationCount}', 'Confirmed', Colors.blue),
          _buildStatItem(Icons.chat_bubble_rounded, '${_comments.length}', 'Comments', Colors.orange),
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
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.secondaryColor)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DESCRIPTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          Text(_complaint.description, style: const TextStyle(color: Color(0xFF455A64), height: 1.6, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final address = _complaint.location['address'] ?? 'Fetching address...';
    final lat = _complaint.location['lat'] as double? ?? 19.0760;
    final lng = _complaint.location['lng'] as double? ?? 72.8777;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('LOCATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, letterSpacing: 1.2)),
              if (_distanceInKm != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${_distanceInKm!.toStringAsFixed(1)} km away', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              TextButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.directions_rounded, size: 16, color: AppTheme.primaryColor),
                label: const Text('Directions', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_rounded, size: 18, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(address, style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.w500, fontSize: 14))),
            ],
          ),
          const SizedBox(height: 16),
          _buildMapCard(lat, lng),
        ],
      ),
    );
  }

  Widget _buildMapCard(double lat, double lng) {
    final complaintPoint = LatLng(lat, lng);
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade100)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: complaintPoint,
            initialZoom: 14,
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
          ),
          children: [
            TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.sadaksevak.citizen'),
            MarkerLayer(
              markers: [
                if (_userLocation != null)
                  Marker(
                    point: _userLocation!,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
                      child: Container(decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                    ),
                  ),
                Marker(
                  point: complaintPoint,
                  child: const Icon(Icons.location_on_rounded, color: Colors.blue, size: 40),
                ),
              ],
            ),
          ],
        ),
      ),
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
          const Text('ATTACHED IMAGES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, letterSpacing: 1.2)),
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
          errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image_outlined, size: 20, color: Colors.grey)),
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
          const Text('REPAIR PROOF', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildPhotoCard(proof['mediaUrl']),
          const SizedBox(height: 12),
          Text(proof['completionNotes'] ?? 'No notes provided.', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String url) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (c, e, s) => Container(
            color: Colors.grey.shade50,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_not_supported_outlined, size: 40, color: Colors.grey.shade300), const Text('Image unavailable', style: TextStyle(color: Colors.grey, fontSize: 12))]),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('STATUS TIMELINE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey, letterSpacing: 1.2)),
          const SizedBox(height: 24),
          _buildTimelineItem('Reported', _dt(_complaint.createdAt), true, true, _complaint.status == 'submitted'),
          _buildTimelineItem('Under Review', _complaint.status != 'submitted' ? 'Active' : '-', _complaint.status != 'submitted', _complaint.status != 'submitted' && _complaint.status != 'under_review', _complaint.status == 'under_review'),
          _buildTimelineItem('Repair Started', _complaint.status.contains('repair') || _complaint.status == 'verified_closed' ? 'Ongoing' : '-', _complaint.status.contains('repair') || _complaint.status == 'verified_closed', _complaint.status == 'verified_closed', _complaint.status == 'repair_started'),
          _buildTimelineItem('Closed', _complaint.status == 'verified_closed' ? 'Finalized' : '-', _complaint.status == 'verified_closed', false, _complaint.status == 'verified_closed', isLast: true),
        ],
      ),
    );
  }

  String _dt(DateTime? date) => date == null ? '-' : DateFormat('dd MMM yyyy • hh:mm a').format(date);

  Widget _buildTimelineItem(String title, String subtitle, bool isCompleted, bool isPast, bool isCurrent, {bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? AppTheme.primaryColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: isCompleted ? AppTheme.primaryColor : Colors.grey.shade200, width: 2),
                ),
                child: isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : isCurrent ? Container(margin: const EdgeInsets.all(6), decoration: const BoxDecoration(color: AppTheme.primaryColor, shape: BoxShape.circle)) : null,
              ),
              if (!isLast) Expanded(child: Container(width: 2, margin: const EdgeInsets.symmetric(vertical: 4), color: isPast ? AppTheme.primaryColor : Colors.grey.shade100)),
            ],
          ),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isCompleted || isCurrent ? AppTheme.secondaryColor : Colors.grey.shade400)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
            ]),
          ),
        ],
      ),
    );
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
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add Comment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppTheme.secondaryColor)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2)),
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
                      SnackBar(content: Text('Login required to comment'), backgroundColor: Colors.orange.shade800),
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
              child: const Text('Post Comment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
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
              icon: const Icon(Icons.forum_rounded, size: 18),
              label: const Text('Live Chat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showAddCommentModal,
              icon: const Icon(Icons.add_comment_rounded, size: 18, color: AppTheme.primaryColor),
              label: const Text('Comment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryColor)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.primaryColor, width: 2),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thanks for your support!'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.teal));
                }
              } catch (e) {
                 if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You have already supported this!'), backgroundColor: Colors.grey));
                  setState(() => _hasSupported = true);
                 }
              }
            },
            child: Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(color: _hasSupported ? Colors.teal.withOpacity(0.1) : Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
              child: Icon(_hasSupported ? Icons.thumb_up_rounded : Icons.thumb_up_outlined, color: _hasSupported ? Colors.teal : AppTheme.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
