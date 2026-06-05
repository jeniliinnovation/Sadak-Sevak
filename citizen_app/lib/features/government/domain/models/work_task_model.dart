class WorkTaskModel {
  final String id;
  final String title;
  final String location;
  final String team;
  final String date;
  final String status;
  final int progress;

  WorkTaskModel({
    required this.id,
    required this.title,
    required this.location,
    required this.team,
    required this.date,
    required this.status,
    required this.progress,
  });
}
