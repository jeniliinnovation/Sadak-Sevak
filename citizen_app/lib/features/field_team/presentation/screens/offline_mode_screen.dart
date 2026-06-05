import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class OfflineModeScreen extends StatelessWidget {
  const OfflineModeScreen({super.key});

  static const Color _blue = Color(0xFF4A80F0);
  static const Color _darkBlue = Color(0xFF0D47A1);

  static const List<Map<String, dynamic>> _offlineActions = [
    {
      'icon': Icons.add_circle_outline,
      'label': 'Create Reports',
    },
    {
      'icon': Icons.update_rounded,
      'label': 'Update Tasks',
    },
    {
      'icon': Icons.photo_camera_outlined,
      'label': 'Take Photos',
    },
    {
      'icon': Icons.map_outlined,
      'label': 'View Maps (Cached)',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Offline Mode',
            style: TextStyle(
                color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Offline Banner ─────────────────────────────────────
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('You are offline',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFFE65100))),
                          const SizedBox(height: 3),
                          Text(
                            'You can continue working in offline mode. Data will be synced when connection is restored.',
                            style: TextStyle(
                                color: Colors.orange.shade700,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // ─── Offline Actions ────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Offline Actions',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _darkBlue)),
                  const SizedBox(height: 14),
                  ..._offlineActions.map((action) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(action['icon'] as IconData,
                                color: _blue, size: 22),
                            const SizedBox(width: 14),
                            Text(action['label'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Color(0xFF1A1A2E))),
                            const Spacer(),
                            const Icon(Icons.chevron_right_rounded,
                                color: Colors.grey, size: 18),
                          ],
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ─── Pending Sync ───────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 160),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pending Sync',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _darkBlue)),
                    const SizedBox(height: 6),
                    Text('6 items will sync when online',
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.list_alt_rounded,
                          size: 18, color: Colors.white),
                      label: const Text('View Pending Items',
                          style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _blue,
                        minimumSize: const Size(double.infinity, 46),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
