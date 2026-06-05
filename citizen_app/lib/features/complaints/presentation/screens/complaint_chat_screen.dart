import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import '../../domain/comment_model.dart';
import '../../data/complaint_repository.dart';
import '../../../../core/network/socket_service.dart';
import '../../../../core/theme/app_theme.dart';

class ComplaintChatScreen extends StatefulWidget {
  final String complaintId;
  final String complaintTitle;

  const ComplaintChatScreen({
    super.key,
    required this.complaintId,
    required this.complaintTitle,
  });

  @override
  State<ComplaintChatScreen> createState() => _ComplaintChatScreenState();
}

class _ComplaintChatScreenState extends State<ComplaintChatScreen> {
  final _complaintRepo = ComplaintRepository();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  List<CommentModel> _messages = [];
  bool _isLoading = true;
  String _currentUserId = '';
  String _currentUserName = '';
  String _token = '';

  @override
  void initState() {
    super.initState();
    _loadUserDataAndConnect();
  }

  @override
  void dispose() {
    SocketService().leaveRoom(widget.complaintId);
    SocketService().stopListeningToMessages();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserDataAndConnect() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token') ?? '';
    _currentUserId = prefs.getString('user_id') ?? '';
    _currentUserName = prefs.getString('user_name') ?? 'User';

    if (_token.isNotEmpty) {
      SocketService().init(_token);
      SocketService().joinRoom(widget.complaintId);
      
      SocketService().listenToMessages((data) {
        if (mounted) {
          setState(() {
            final newMessage = CommentModel.fromJson(data);
            // Deduplicate if already loaded
            if (!_messages.any((m) => m.id == newMessage.id)) {
              _messages.add(newMessage);
            }
          });
          _scrollToBottom();
        }
      });
    }

    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final comments = await _complaintRepo.getComments(widget.complaintId);
      if (mounted) {
        setState(() {
          _messages = comments;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Send via WebSocket
    SocketService().sendMessage(widget.complaintId, _currentUserId, text);
    _messageController.clear();
    _scrollToBottom();
  }

  Widget _buildRoleBadge(String? role) {
    if (role == null) return const SizedBox.shrink();

    String label;
    Color color;

    switch (role.toLowerCase()) {
      case 'admin':
        label = 'Admin';
        color = Colors.red.shade600;
        break;
      case 'department_head':
        label = 'Gov Head';
        color = const Color(0xFFF4511E); // Orange
        break;
      case 'government':
        label = 'Gov Staff';
        color = const Color(0xFFF4511E); // Orange
        break;
      case 'team_member':
        label = 'Field Team';
        color = const Color(0xFF4A80F0); // Blue
        break;
      case 'citizen':
      default:
        label = 'Citizen';
        color = const Color(0xFF2E7D32); // Green
    }

    return Container(
      margin: const EdgeInsets.only(left: 6),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppTheme.primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.secondaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Discussion Room',
              style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 2),
            Text(
              widget.complaintTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          // Connection Status Indicator
          ValueListenableBuilder<bool>(
            valueListenable: SocketService().connectionNotifier,
            builder: (context, isConnected, child) {
              return Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isConnected ? 'Live' : 'Connecting...',
                    style: TextStyle(
                      color: isConnected ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Info Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: primaryColor.withOpacity(0.06),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 14, color: primaryColor.withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'This group chat connects the Citizen, assigned Field Team, and Gov Officers.',
                      style: TextStyle(color: primaryColor.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            
            // Messages List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.forum_outlined, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet in this discussion.',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Send a message to start the conversation!',
                                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isMe = message.userId == _currentUserId;

                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: FadeInUp(
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isMe ? primaryColor : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(16),
                                      topRight: const Radius.circular(16),
                                      bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                                      bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Sender Name & Role
                                      if (!isMe)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              message.userName,
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            _buildRoleBadge(message.userRole),
                                          ],
                                        )
                                      else
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text(
                                              'You',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                            _buildRoleBadge(message.userRole),
                                          ],
                                        ),
                                      const SizedBox(height: 6),
                                      
                                      // Message Body
                                      Text(
                                        message.content,
                                        style: TextStyle(
                                          color: isMe ? Colors.white : AppTheme.secondaryColor,
                                          fontSize: 14,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      // Timestamp
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          DateFormat('hh:mm a').format(message.createdAt),
                                          style: TextStyle(
                                            color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey.shade400,
                                            fontSize: 9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
            
            // Input Text Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  )
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _messageController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.black87, fontSize: 15),
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Send Button
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
