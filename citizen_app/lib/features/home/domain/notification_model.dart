import 'package:flutter/material.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'status_update',
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  IconData get icon {
    switch (type) {
      case 'status_update': return Icons.update_rounded;
      case 'comment': return Icons.chat_bubble_outline_rounded;
      case 'escalation': return Icons.warning_amber_rounded;
      case 'broadcast': return Icons.campaign_outlined;
      default: return Icons.notifications_none_rounded;
    }
  }

  Color get color {
    switch (type) {
      case 'status_update': return Colors.blue;
      case 'comment': return Colors.orange;
      case 'escalation': return Colors.red;
      case 'broadcast': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
