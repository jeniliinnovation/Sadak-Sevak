import 'package:dio/dio.dart';
import 'package:sadak_sevak_citizen/core/network/dio_client.dart';
import 'package:sadak_sevak_citizen/features/complaints/domain/complaint_model.dart';
import 'package:sadak_sevak_citizen/features/auth/domain/user_model.dart';
import '../domain/models/contractor_model.dart';
import '../domain/models/analytics_model.dart';
import '../domain/models/notification_model.dart';
import '../domain/models/approval_model.dart';
import '../domain/models/work_task_model.dart';
import '../domain/models/field_operation_model.dart';
import '../domain/models/audit_log_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GovernmentRepository {
  final Dio _dio = DioClient().dio;

  Future<List<Complaint>> getComplaints() async {
    try {
      final response = await _dio.get('complaints');
      return (response.data as List)
          .map((json) => Complaint.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Complaint>> getAssignedTasks() async {
    try {
      final response = await _dio.get('complaints/my-team');
      return (response.data as List)
          .map((json) => Complaint.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Complaint>> getAssignedCompletedComplaints() async {
    try {
      final response = await _dio.get('complaints/my-team/completed');
      return (response.data as List)
          .map((json) => Complaint.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Contractor>> getContractors() async {
    try {
      final response = await _dio.get('admin/contractors');
      return (response.data as List)
          .map((json) => Contractor.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('admin/users');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AnalyticsSummary> getAnalyticsSummary() async {
    try {
      final complaints = await getComplaints();
      
      int total = complaints.length;
      int progress = 0;
      int done = 0;
      int pending = 0;
      
      Map<String, int> categoryCounts = {};
      List<double> monthlyTrend = List.filled(6, 0.0);
      final now = DateTime.now();

      for (var c in complaints) {
        final status = c.status.toLowerCase();
        if (status == 'repair_started' || status == 'team_assigned') {
          progress++;
        } else if (status == 'repair_completed' || status == 'verified_closed') {
          done++;
        } else if (status == 'submitted' || status == 'pending') {
          pending++;
        }
        
        // Category breakdown
        final category = c.category;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
        
        // Monthly trend (last 6 months)
        if (c.createdAt != null) {
          int monthDiff = (now.year - c.createdAt!.year) * 12 + now.month - c.createdAt!.month;
          if (monthDiff >= 0 && monthDiff < 6) {
            monthlyTrend[5 - monthDiff] += 1.0;
          }
        }
      }
      
      // Calculate category percentages
      Map<String, double> categoryPercentages = {};
      if (total > 0) {
        categoryCounts.forEach((key, value) {
          categoryPercentages[key] = value / total;
        });
      }
      
      return AnalyticsSummary(
        totalComplaints: total,
        inProgress: progress,
        completed: done,
        pendingApprovals: pending,
        monthlyTrend: monthlyTrend,
        categoryCounts: categoryCounts,
        categoryPercentages: categoryPercentages,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Complaint> assignComplaintTeam(String complaintId, String teamId) async {
    try {
      final response = await _dio.put(
        'admin/complaints/$complaintId/assign',
        data: {'teamId': teamId},
      );
      return Complaint.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  // --- Real Endpoints for Profile and Notifications ---

  Future<User> getProfile() async {
    try {
      final response = await _dio.get('auth/profile');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

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

  Future<void> markNotificationAsRead(String id) async {
    try {
      await _dio.put('notifications/$id/read');
    } catch (e) {
      rethrow;
    }
  }

  // --- Simulated Endpoints for Missing Backend Routes ---

  Future<List<ApprovalModel>> getApprovals() async {
    final complaints = await getComplaints();
    final pending = complaints.where((c) => c.status.toLowerCase() == 'submitted' || c.status.toLowerCase() == 'pending').toList();
    
    return pending.map((c) {
      final loc = c.location != null ? c.location!['area'] ?? c.location!['address'] ?? 'Unknown' : 'Unknown';
      final dateStr = c.createdAt != null ? DateFormat('MMM dd, yyyy').format(c.createdAt!) : 'Unknown Date';
      
      return ApprovalModel(
        id: c.id.substring(0, 8).toUpperCase(),
        title: c.title,
        zone: loc,
        requestedBy: 'Citizen',
        date: dateStr,
        priority: c.priority,
        cost: 'TBD',
        status: 'Pending',
      );
    }).toList();
  }

  Future<List<WorkTaskModel>> getWorkTasks() async {
    final complaints = await getComplaints();
    List<User> users = [];
    try { users = await getUsers(); } catch (_) {}
    final userMap = {for (var u in users) u.id: u.name};

    final tasks = complaints.where((c) => c.status.toLowerCase() != 'submitted' && c.status.toLowerCase() != 'pending').toList();
    
    return tasks.map((c) {
      final loc = c.location != null ? c.location!['address'] ?? 'Unknown location' : 'Unknown location';
      final dateStr = c.createdAt != null ? DateFormat('MMM dd, yyyy').format(c.createdAt!) : 'Unknown Date';
      
      String teamName = 'Assigned Team';
      if (c.assignedTeamId != null && userMap.containsKey(c.assignedTeamId)) {
        teamName = userMap[c.assignedTeamId]!;
      }

      int progress = 0;
      if (c.status.toLowerCase() == 'repair_started') progress = 50;
      if (c.status.toLowerCase() == 'repair_completed' || c.status.toLowerCase() == 'verified_closed') progress = 100;

      return WorkTaskModel(
        id: 'WRK-${c.id.substring(0, 4).toUpperCase()}',
        title: c.title,
        location: loc,
        team: teamName,
        date: dateStr,
        status: c.status.replaceAll('_', ' ').toUpperCase(),
        progress: progress,
      );
    }).toList();
  }

  Future<List<FieldOperationModel>> getFieldOperations() async {
    final complaints = await getComplaints();
    List<User> users = [];
    try {
      users = await getUsers();
    } catch (e) {
      // Ignore if users cannot be fetched
    }
    final userMap = {for (var u in users) u.id: u.name};

    final active = complaints.where((c) => c.status.toLowerCase() == 'team_assigned' || c.status.toLowerCase() == 'repair_started').toList();
    return active.map((c) {
      final loc = c.location != null ? c.location!['address'] ?? 'Unknown location' : 'Unknown location';
      final lat = c.location != null ? double.tryParse(c.location!['lat'].toString()) ?? 22.3039 : 22.3039;
      final lng = c.location != null ? double.tryParse(c.location!['lng'].toString()) ?? 70.8022 : 70.8022;
      
      String teamName = 'Assigned Team';
      if (c.assignedTeamId != null && userMap.containsKey(c.assignedTeamId)) {
        teamName = userMap[c.assignedTeamId]!;
      }

      return FieldOperationModel(
        title: c.category ?? 'Maintenance Work',
        location: loc,
        team: teamName,
        time: 'In Progress',
        type: c.category?.toLowerCase() == 'inspection' ? 'inspection' : 'repair',
        coordinates: LatLng(lat, lng),
      );
    }).toList();
  }

  Future<List<AuditLogModel>> getAuditLogs() async {
    try {
      final notifications = await getNotifications();
      return notifications.map((n) {
        final dateStr = n.createdAt != null ? DateFormat('MMM dd, yyyy - hh:mm a').format(n.createdAt!) : 'Unknown Time';
        return AuditLogModel(
          id: n.id.substring(0, 8).toUpperCase(),
          action: n.title,
          user: 'System', // Can be refined if we know exact actor
          timestamp: dateStr,
          details: n.message,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
