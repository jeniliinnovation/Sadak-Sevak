import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import 'package:sadak_sevak_citizen/features/government/data/government_repository.dart';
import 'package:sadak_sevak_citizen/features/government/domain/models/analytics_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class GovernmentDashboardScreen extends StatefulWidget {
  const GovernmentDashboardScreen({super.key});

  @override
  State<GovernmentDashboardScreen> createState() =>
      _GovernmentDashboardScreenState();
}

class _GovernmentDashboardScreenState extends State<GovernmentDashboardScreen> {
  String selectedPeriod = 'This Year';
  final GovernmentRepository _repository = GovernmentRepository();
  bool _isLoading = true;
  AnalyticsSummary? _summary;
  String _userName = 'Govt. Officer';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _fetchData();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Govt. Officer';
    });
  }

  Future<void> _fetchData() async {
    try {
      final summary = await _repository.getAnalyticsSummary();
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFF4511E);
    const darkOrange = Color(0xFFD84315);
    const lightOrangeBg = Color(0xFFFFF3E0);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 60,
                  left: 24,
                  right: 24,
                  bottom: 32,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryOrange, darkOrange],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33F4511E),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Shield and Brand
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white30,
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.account_balance_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Government Staff',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        // Notification Bell
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications_none_rounded,
                              color: Colors.white,
                            ),
                            onPressed: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Good Morning, $_userName 🤝',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Overview of road maintenance and complaint operations',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Statistics Grid Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'MMM dd, yyyy',
                                ).format(DateTime.now()),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.grey.shade400,
                                size: 18,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_isLoading)
                            const Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFF4511E),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatBlock(
                                        'Total Complaints',
                                        _summary?.totalComplaints.toString() ??
                                            '0',
                                        'Current count',
                                        Colors.blue.shade600,
                                        Colors.blue.shade50,
                                        Icons.assignment_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatBlock(
                                        'In-Progress',
                                        _summary?.inProgress.toString() ?? '0',
                                        'Currently assigned',
                                        primaryOrange,
                                        lightOrangeBg,
                                        Icons.sync_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatBlock(
                                        'Completed',
                                        _summary?.completed.toString() ?? '0',
                                        'Repairs finished',
                                        Colors.green.shade600,
                                        Colors.green.shade50,
                                        Icons.check_circle_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatBlock(
                                        'Pending Action',
                                        _summary?.pendingApprovals.toString() ??
                                            '0',
                                        'Requires attention',
                                        Colors.red.shade600,
                                        Colors.red.shade50,
                                        Icons.pending_actions_rounded,
                                        isAlert: true,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Complaints Trend Line Chart
                  FadeInUp(
                    duration: const Duration(milliseconds: 700),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Complaints Trend',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF263238),
                                ),
                              ),
                              DropdownButton<String>(
                                value: selectedPeriod,
                                underline: const SizedBox(),
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: primaryOrange,
                                ),
                                style: const TextStyle(
                                  color: primaryOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                items:
                                    <String>[
                                      'This Month',
                                      'This Year',
                                      'All Time',
                                    ].map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (value) {
                                  setState(() => selectedPeriod = value!);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: CustomPaint(
                              painter: LineChartPainter(
                                _summary?.monthlyTrend ?? [0, 0, 0, 0, 0, 0],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              final date = DateTime.now().subtract(
                                Duration(days: 30 * (5 - index)),
                              );
                              return Text(
                                DateFormat('MMM').format(date),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Top Complaint Categories Donut Chart
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Top Complaint Categories',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF263238),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              SizedBox(
                                height: 130,
                                width: 130,
                                child: CustomPaint(
                                  painter: DonutChartPainter(
                                    _summary?.categoryPercentages ?? {},
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    final percents =
                                        _summary?.categoryPercentages ?? {};
                                    final sortedKeys = percents.keys.toList()
                                      ..sort(
                                        (a, b) => percents[b]!.compareTo(
                                          percents[a]!,
                                        ),
                                      );
                                    final colors = [
                                      const Color(0xFFF4511E),
                                      const Color(0xFFFFB300),
                                      const Color(0xFF1E88E5),
                                      const Color(0xFF43A047),
                                      Colors.grey.shade400,
                                      Colors.purple,
                                      Colors.teal,
                                      Colors.pink,
                                    ];
                                    return Column(
                                      children: List.generate(
                                        min(sortedKeys.length, 5),
                                        (index) {
                                          final category = sortedKeys[index];
                                          final percentValue =
                                              (percents[category]! * 100)
                                                  .toStringAsFixed(0);
                                          return _buildCategoryLegend(
                                            category,
                                            '$percentValue%',
                                            colors[index % colors.length],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBlock(
    String title,
    String value,
    String trend,
    Color color,
    Color bgColor,
    IconData icon, {
    bool isAlert = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              if (isAlert)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'HIGH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color.withOpacity(0.85),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(
              fontSize: 8,
              color: isAlert ? Colors.red.shade700 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLegend(String title, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF546E7A),
              ),
            ),
          ),
          Text(
            percent,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF263238),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for complaints trend (line chart)
class LineChartPainter extends CustomPainter {
  final List<double> dataPoints;

  LineChartPainter(this.dataPoints);

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFFF4511E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFF4511E).withOpacity(0.3),
          const Color(0xFFF4511E).withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    double maxVal = dataPoints.reduce(max);
    if (maxVal == 0) maxVal = 1; // Prevent division by zero
    maxVal = (maxVal * 1.2).ceilToDouble(); // Add some padding on top

    final Path path = Path();
    final Path fillPath = Path();

    final double xStep = size.width / (dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * xStep;
      final double y = size.height - (dataPoints[i] / maxVal * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // Draw cubic bezier curve for smoother line
        final prevX = (i - 1) * xStep;
        final prevY = size.height - (dataPoints[i - 1] / maxVal * size.height);
        path.cubicTo((prevX + x) / 2, prevY, (prevX + x) / 2, y, x, y);
        fillPath.cubicTo((prevX + x) / 2, prevY, (prevX + x) / 2, y, x, y);
      }

      if (i == dataPoints.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    // Grid lines helper
    final gridPaint = Paint()
      ..color = Colors.grey.shade100
      ..strokeWidth = 1;
    for (int i = 0; i < 4; i++) {
      final double y = size.height / 3 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw point dots
    final dotPaint = Paint()
      ..color = const Color(0xFFF4511E)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * xStep;
      final double y = size.height - (dataPoints[i] / maxVal * size.height);
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 5, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Top categories (donut/pie chart)
class DonutChartPainter extends CustomPainter {
  final Map<String, double> categoryPercentages;

  DonutChartPainter(this.categoryPercentages);

  @override
  void paint(Canvas canvas, Size size) {
    if (categoryPercentages.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final rect = Rect.fromCircle(center: center, radius: radius);

    final sortedKeys = categoryPercentages.keys.toList()
      ..sort(
        (a, b) => categoryPercentages[b]!.compareTo(categoryPercentages[a]!),
      );
    final percentages = sortedKeys
        .take(5)
        .map((k) => categoryPercentages[k]!)
        .toList();

    // Normalize to 100% just in case we took top 5
    double sum = percentages.fold(0, (prev, val) => prev + val);
    if (sum > 0 && sum < 1) {
      percentages.add(1.0 - sum); // Add "Others" conceptually
    }
    final List<Color> colors = [
      const Color(0xFFF4511E),
      const Color(0xFFFFB300),
      const Color(0xFF1E88E5),
      const Color(0xFF43A047),
      Colors.grey.shade400,
    ];

    double startAngle = -pi / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.square;

    for (int i = 0; i < percentages.length; i++) {
      paint.color = colors[i];
      final sweepAngle = percentages[i] * 2 * pi;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
