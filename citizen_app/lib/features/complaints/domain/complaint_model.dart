class Complaint {
  final String id;
  final String title;
  final String description;
  final String status;
  final String category;
  final String priority;
  final Map<String, dynamic> location;
  final dynamic media; // Using dynamic to avoid subtype errors during transitions
  int likesCount;
  int confirmationCount;
  final DateTime? createdAt;
  final DateTime? lastStatusUpdate;
  final Map<String, dynamic>? repairProof;
  final String? assignedTeamId;

  Complaint({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.location,
    this.category = 'General',
    this.priority = 'Medium',
    this.media,
    this.likesCount = 0,
    this.confirmationCount = 0,
    this.createdAt,
    this.lastStatusUpdate,
    this.repairProof,
    this.assignedTeamId,
  });

  // Safe helper to always get media as a list
  List<dynamic> get mediaList {
    if (media == null) return [];
    if (media is List) return media;
    if (media is Map) return [media];
    return [];
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'submitted',
      category: json['category'] ?? 'General',
      priority: json['priority'] ?? 'Medium',
      location: json['location'] is Map ? json['location'] : {},
      media: json['media'], // Keep original format, let getter handle conversion
      likesCount: json['likesCount'] ?? 0,
      confirmationCount: json['confirmationCount'] ?? 0,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      lastStatusUpdate: json['lastStatusUpdate'] != null ? DateTime.parse(json['lastStatusUpdate']) : null,
      repairProof: json['repairProof'] is Map ? json['repairProof'] : null,
      assignedTeamId: json['assignedTeamId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'category': category,
      'priority': priority,
      'location': location,
      'media': media,
      'likesCount': likesCount,
      'confirmationCount': confirmationCount,
      'assignedTeamId': assignedTeamId,
    };
  }
}
