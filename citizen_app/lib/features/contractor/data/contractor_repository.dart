import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sadak_sevak_citizen/core/network/dio_client.dart';
import 'package:sadak_sevak_citizen/features/complaints/domain/complaint_model.dart';

class ContractorRepository {
  final Dio _dio = DioClient().dio;

  // Fetch active and completed complaints assigned to the contractor from the database
  Future<List<Map<String, dynamic>>> getMyWorkOrders() async {
    try {
      final List<Map<String, dynamic>> projects = [];

      // 1. Fetch active assigned complaints
      try {
        final response = await _dio.get('complaints/my-team');
        final list = response.data as List;
        for (var json in list) {
          final complaint = Complaint.fromJson(json);
          projects.add(_mapComplaintToProject(complaint));
        }
      } catch (e) {
        // Log/ignore and try next
      }

      // 2. Fetch completed assigned complaints
      try {
        final response = await _dio.get('complaints/my-team/completed');
        final list = response.data as List;
        for (var json in list) {
          final complaint = Complaint.fromJson(json);
          projects.add(_mapComplaintToProject(complaint));
        }
      } catch (e) {
        // Log/ignore
      }

      return projects;
    } catch (e) {
      return [];
    }
  }

  // Update status of assigned complaint in the database
  Future<void> updateComplaintStatus(String id, String status) async {
    try {
      if (id.startsWith('#')) {
        // It's a mock project, mock success
        return;
      }
      // Map project status back to backend database enums
      String backendStatus = 'team_assigned';
      if (status == 'Assigned') {
        backendStatus = 'team_assigned';
      } else if (status == 'In Progress') {
        backendStatus = 'repair_started';
      } else if (status == 'Completed' || status == 'Inspection Pending') {
        backendStatus = 'repair_completed';
      }

      await _dio.put(
        'complaints/$id/status',
        data: {'status': backendStatus},
      );
    } catch (e) {
      rethrow;
    }
  }

  // Helper mapper to translate raw DB Complaint to the UI expected project map
  Map<String, dynamic> _mapComplaintToProject(Complaint complaint) {
    // Determine user friendly status and progress
    String uiStatus = 'Assigned';
    int progress = 0;
    
    switch (complaint.status.toLowerCase()) {
      case 'team_assigned':
        uiStatus = 'Assigned';
        progress = 10;
        break;
      case 'repair_started':
      case 'repair_in_progress':
        uiStatus = 'In Progress';
        progress = 50;
        break;
      case 'repair_completed':
        uiStatus = 'Completed';
        progress = 100;
        break;
      case 'verified_closed':
        uiStatus = 'Completed';
        progress = 100;
        break;
      default:
        uiStatus = 'Assigned';
        progress = 0;
    }

    return {
      'id': complaint.id,
      'title': complaint.title,
      'roadName': complaint.location?['address'] ?? complaint.location?['area'] ?? complaint.title,
      'location': complaint.location?['address'] ?? complaint.location?['area'] ?? 'Rajkot',
      'assignedDate': complaint.createdAt != null 
          ? '${complaint.createdAt!.day}/${complaint.createdAt!.month}/${complaint.createdAt!.year}'
          : 'Recent',
      'dueDate': complaint.createdAt != null
          ? '${complaint.createdAt!.add(const Duration(days: 14)).day}/${complaint.createdAt!.add(const Duration(days: 14)).month}/${complaint.createdAt!.add(const Duration(days: 14)).year}'
          : 'Pending',
      'priority': complaint.priority,
      'status': uiStatus,
      'progress': progress,
      'description': complaint.description,
      'officerName': 'Mr. Amit Verma',
      'officerContact': '9090909090',
      'latitude': complaint.latitude,
      'longitude': complaint.longitude,
    };
  }

  // Submit a bid to the database
  Future<void> submitBid(String complaintId, double cost, String duration, String message) async {
    try {
      await _dio.post(
        'bids',
        data: {
          'complaintId': complaintId,
          'cost': cost,
          'duration': duration,
          'message': message,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // Fetch all bids submitted by the current contractor
  Future<List<Map<String, dynamic>>> getMyBids() async {
    try {
      final response = await _dio.get('bids/my');
      final list = response.data as List;
      return list.map((json) => json as Map<String, dynamic>).toList();
    } catch (e) {
      return [];
    }
  }
}
