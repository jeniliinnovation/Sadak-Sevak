import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final DateTime? createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    IconData iconData = Icons.notifications;
    Color colorValue = Colors.blue;
    String type = json['type'] ?? '';

    switch (type.toLowerCase()) {
      case 'status_update':
        iconData = Icons.construction_rounded;
        colorValue = Colors.amber;
        break;
      case 'assignment':
        iconData = Icons.campaign_rounded;
        colorValue = Colors.orange;
        break;
      case 'escalation':
        iconData = Icons.warning_rounded;
        colorValue = Colors.red;
        break;
      case 'broadcast':
        iconData = Icons.campaign_rounded;
        colorValue = Colors.blue;
        break;
      default:
        iconData = Icons.notifications;
        colorValue = Colors.blue;
    }

    DateTime? parsedDate;
    String timeStr = 'Just now';
    if (json['createdAt'] != null) {
      parsedDate = DateTime.tryParse(json['createdAt'].toString());
      if (parsedDate != null) {
        timeStr = DateFormat('MMM dd, hh:mm a').format(parsedDate);
      }
    }

    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Notification',
      message: json['message'] ?? '',
      time: timeStr,
      icon: iconData,
      color: colorValue,
      createdAt: parsedDate,
      isRead: json['isRead'] ?? false,
    );
  }
}
