class ApprovalModel {
  final String id;
  final String title;
  final String zone;
  final String requestedBy;
  final String date;
  final String priority;
  final String cost;
  String status;

  ApprovalModel({
    required this.id,
    required this.title,
    required this.zone,
    required this.requestedBy,
    required this.date,
    required this.priority,
    required this.cost,
    required this.status,
  });
}
