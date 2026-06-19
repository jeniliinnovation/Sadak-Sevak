import 'package:dio/dio.dart';
import 'package:sadak_sevak_citizen/core/network/dio_client.dart';
import '../domain/notification_model.dart';

class NotificationRepository {
  final Dio _dio = DioClient().dio;

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await _dio.get('notifications');
      return (response.data as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('notifications/unread-count');
      return (response.data['count'] as num).toInt();
    } catch (e) {
      return 0;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dio.put('notifications/$id/read');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.put('notifications/read-all');
    } catch (e) {
      rethrow;
    }
  }
}

