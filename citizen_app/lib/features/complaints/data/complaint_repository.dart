import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import 'package:sadak_sevak_citizen/core/network/dio_client.dart';
import '../domain/complaint_model.dart';
import '../domain/comment_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class ComplaintRepository {
  final Dio _dio = DioClient().dio;

  Future<List<CommentModel>> getComments(String complaintId) async {
    try {
      final response = await _dio.get('complaints/$complaintId/comments');
      return (response.data as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Complaint>> getMyComplaints() async {
    try {
      final response = await _dio.get(ApiConstants.myComplaints);
      return (response.data as List)
          .map((json) => Complaint.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Complaint>> getAllComplaints() async {
    try {
      final response = await _dio.get(ApiConstants.complaints);
      return (response.data as List)
          .map((json) => Complaint.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Complaint>> getNearbyComplaints(double lat, double lng) async {
    try {
      final response = await _dio.get(
        ApiConstants.nearbyComplaints,
        queryParameters: {'lat': lat, 'lng': lng},
      );
      return (response.data as List)
          .map((json) => Complaint.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Complaint> createComplaint({
    required String title,
    required String description,
    required double lat,
    required double lng,
    String? imageUrl,
    String? category,
    String? priority,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.complaints,
        data: {
          'title': title,
          'description': description,
          'location': {
            'lat': lat,
            'lng': lng,
          },
          'category': category,
          'priority': priority,
          if (imageUrl != null)
            'media': {
              'url': imageUrl,
              'type': 'image',
            },
        },
      );
      return Complaint.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadMedia(String filePath, {bool isVideo = false}) async {
    try {
      MultipartFile file;
      if (kIsWeb) {
        final bytes = await XFile(filePath).readAsBytes();
        file = MultipartFile.fromBytes(bytes, filename: isVideo ? 'video.mp4' : 'image.jpg');
      } else {
        file = await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        );
      }

      final formData = FormData.fromMap({
        'file': file,
      });

      final response = await _dio.post(
        'media/upload',
        data: formData,
      );
      return response.data['url'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Complaint> getComplaintById(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.complaints}/$id');
      return Complaint.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addComment(String complaintId, String content) async {
    try {
      await _dio.post(
        'complaints/$complaintId/comments',
        data: {'content': content},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> likeComplaint(String id) async {
    try {
      await _dio.post('complaints/$id/like');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> confirmComplaint(String id) async {
    try {
      await _dio.post('complaints/$id/confirm');
    } catch (e) {
      rethrow;
    }
  }
}
