class AuditLogModel {
  final String id;
  final String action;
  final String user;
  final String timestamp;
  final String details;

  AuditLogModel({
    required this.id,
    required this.action,
    required this.user,
    required this.timestamp,
    required this.details,
  });
}
