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
  final String? assignedTeamName;
  final String? citizenId;
  final String? citizenName;

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
    this.assignedTeamName,
    this.citizenId,
    this.citizenName,
  });

  // Safe helper to always get media as a list
  List<dynamic> get mediaList {
    if (media == null) return [];
    if (media is List) return media;
    if (media is Map) return [media];
    return [];
  }

  double get latitude => _parseCoordinate(location['lat']);
  double get longitude => _parseCoordinate(location['lng']);
  bool get hasLocation => latitude != 0.0 || longitude != 0.0;

  static double _parseCoordinate(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  factory Complaint.fromJson(Map<String, dynamic> json) {
    String? citizenName;
    if (json['citizen'] is Map) {
      citizenName = json['citizen']['name']?.toString();
    } else if (json['citizenName'] != null) {
      citizenName = json['citizenName'].toString();
    }

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
      assignedTeamName: json['team'] is Map
          ? json['team']['name']?.toString()
          : json['assignedTeamName']?.toString(),
      citizenId: json['citizenId']?.toString() ?? json['citizen_id']?.toString(),
      citizenName: citizenName,
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
      'assignedTeamName': assignedTeamName,
      'citizenId': citizenId,
      'citizenName': citizenName,
    };
  }
}
