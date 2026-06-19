import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';

class ContractorPaymentsScreen extends StatelessWidget {
  const ContractorPaymentsScreen({super.key});

  final List<Map<String, dynamic>> _paymentHistory = const [
    {'title': 'MG Road Repair', 'id': '#PAY-2025-001', 'date': '15 May 2025', 'amount': '₹1,20,000', 'isPaid': true},
    {'title': 'Highway Crack Repair', 'id': '#PAY-2025-002', 'date': '12 May 2025', 'amount': '₹90,000', 'isPaid': true},
    {'title': 'Drainage Construction', 'id': '#PAY-2025-003', 'date': 'Pending', 'amount': '₹75,000', 'isPaid': false},
    {'title': 'Street Light Installation', 'id': '#PAY-2025-004', 'date': 'Pending', 'amount': '₹60,000', 'isPaid': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = false;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payments',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.secondaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // KPI Summary Cards
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    'Total Earnings',
                    '₹6,45,000',
                    isDark ? Colors.white : AppTheme.secondaryColor,
                    isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    'Paid Amount',
                    '₹4,00,000',
                    isDark ? Colors.green.shade300 : Colors.green.shade700,
                    isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKpiCard(
                    'Pending Amount',
                    '₹2,45,000',
                    isDark ? Colors.red.shade300 : Colors.red.shade700,
                    isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Payment History list
            Text(
              'Payment History',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _paymentHistory.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _paymentHistory[index];
                final isPaid = item['isPaid'] as bool;
                final chipText = isPaid ? 'Paid' : 'Pending';
                final chipColor = isPaid
                    ? (isDark ? Colors.green.shade300 : const Color(0xFF2E7D32))
                    : (isDark ? Colors.orange.shade300 : const Color(0xFFF57C00));
                final chipBg = isPaid
                    ? (isDark ? Colors.green.shade900.withOpacity(0.3) : const Color(0xFFE8F5E9))
                    : (isDark ? Colors.orange.shade900.withOpacity(0.3) : const Color(0xFFFFF4E5));

                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    title: Text(
                      item['title']!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          item['id']!,
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isPaid ? 'Paid on: ${item['date']}' : 'Status: Pending Approval',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item['amount']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : AppTheme.secondaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: chipBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            chipText,
                            style: TextStyle(
                              color: chipColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(String label, String value, Color textColor, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
