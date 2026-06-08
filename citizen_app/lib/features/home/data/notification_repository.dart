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

  Future<void> markAsRead(String id) async {
    try {
      await _dio.put('notifications/$id/read');
    } catch (e) {
      rethrow;
    }
  }
}
