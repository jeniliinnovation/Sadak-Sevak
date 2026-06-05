import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'government_dashboard_screen.dart' show LineChartPainter;
import 'dart:math';
import 'package:intl/intl.dart';

import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/government/domain/models/analytics_model.dart';

class GovernmentAnalyticsScreen extends StatefulWidget {
  const GovernmentAnalyticsScreen({super.key});

  @override
  State<GovernmentAnalyticsScreen> createState() => _GovernmentAnalyticsScreenState();
}

class _GovernmentAnalyticsScreenState extends State<GovernmentAnalyticsScreen> {
  final GovernmentRepository _repository = GovernmentRepository();
  bool _isLoading = true;
  AnalyticsSummary? _summary;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    try {
      final summary = await _repository.getAnalyticsSummary();
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          'Analytics & Reports',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator(color: primaryOrange))
        : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Stats Row
            FadeInUp(
              duration: const Duration(milliseconds: 400),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      'Total Complaints',
                      _summary?.totalComplaints.toString() ?? '0',
                      '▲ Live',
                      const [Color(0xFF2196F3), Color(0xFF1976D2)],
                      Icons.report_problem_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Completed Works',
                      _summary?.completed.toString() ?? '0',
                      '▲ Live',
                      const [Color(0xFF4CAF50), Color(0xFF388E3C)],
                      Icons.check_circle_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricCard(
                      'Pending Works',
                      _summary?.pendingApprovals.toString() ?? '0',
                      '▲ Live',
                      const [Color(0xFFF4511E), Color(0xFFD84315)],
                      Icons.pending_actions_rounded,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Complaints Trend Chart
            FadeInUp(
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Complaints Trend',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF263238)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'This Year',
                            style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: LineChartPainter(_summary?.monthlyTrend ?? [0,0,0,0,0,0]),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final date = DateTime.now().subtract(Duration(days: 30 * (5 - index)));
                        return Text(
                          DateFormat('MMM').format(date),
                          style: const TextStyle(color: Colors.grey, fontSize: 10)
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Top Complaint Categories Horizontal Bar Chart
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.shade100, blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Complaint Categories',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF263238)),
                    ),
                    const SizedBox(height: 20),
                    Builder(builder: (context) {
                      final percents = _summary?.categoryPercentages ?? {};
                      if (percents.isEmpty) {
                        return const Center(child: Text('No data'));
                      }
                      final sortedKeys = percents.keys.toList()..sort((a, b) => percents[b]!.compareTo(percents[a]!));
                      final colors = [
                        Colors.orange,
                        Colors.blue,
                        Colors.teal,
                        Colors.amber,
                        Colors.grey.shade400,
                        Colors.purple,
                        Colors.pink,
                      ];
                      return Column(
                        children: List.generate(
                          min(sortedKeys.length, 5),
                          (index) {
                            final category = sortedKeys[index];
                            final val = percents[category]!;
                            return _buildHorizontalBar(category, val, colors[index % colors.length]);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, String percent, List<Color> gradientColors, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              percent,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalBar(String label, double val, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF546E7A)),
              ),
              Text(
                '${(val * 100).toInt()}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Color(0xFF263238)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: val,
              color: color,
              backgroundColor: Colors.grey.shade100,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
