class AnalyticsSummary {
  final int totalComplaints;
  final int inProgress;
  final int completed;
  final int pendingApprovals;
  final List<double> monthlyTrend;
  final Map<String, double> categoryPercentages;
  final Map<String, int> categoryCounts;
  
  AnalyticsSummary({
    this.totalComplaints = 0,
    this.inProgress = 0,
    this.completed = 0,
    this.pendingApprovals = 0,
    this.monthlyTrend = const [],
    this.categoryPercentages = const {},
    this.categoryCounts = const {},
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    int total = 0;
    int progress = 0;
    int done = 0;
    int pending = 0;

    if (json['complaintStats'] is List) {
      for (var stat in json['complaintStats']) {
        final count = stat['count'] ?? 0;
        total += (count as int);
        final status = stat['status']?.toString().toLowerCase() ?? '';
        if (status == 'repair_started' || status == 'team_assigned') {
          progress += count;
        } else if (status == 'repair_completed' || status == 'verified_closed') {
          done += count;
        } else if (status == 'submitted' || status == 'pending') {
          pending += count;
        }
      }
    }

    return AnalyticsSummary(
      totalComplaints: total,
      inProgress: progress,
      completed: done,
      pendingApprovals: pending,
    );
  }
}
