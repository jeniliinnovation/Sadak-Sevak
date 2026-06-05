import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class SyncDataScreen extends StatefulWidget {
  const SyncDataScreen({super.key});

  @override
  State<SyncDataScreen> createState() => _SyncDataScreenState();
}

class _SyncDataScreenState extends State<SyncDataScreen> {
  bool _autoSync = true;
  bool _syncing = false;
  static const Color _blue = Color(0xFF4A80F0);
  static const Color _darkBlue = Color(0xFF0D47A1);

  Future<void> _doSync() async {
    setState(() => _syncing = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _syncing = false);
  }

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
        title: const Text('Sync Data',
            style: TextStyle(
                color: _darkBlue, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ─── Ready to Sync Card ─────────────────────────────────
            FadeInDown(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _blue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _syncing
                            ? Icons.sync_rounded
                            : Icons.cloud_download_outlined,
                        color: _blue,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _syncing ? 'Syncing...' : 'Ready to Sync',
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _darkBlue),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _syncing
                          ? 'Uploading data to server...'
                          : 'All data will be synced with\ncentral server',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Text('Last Sync: May 12, 2025 09:30 AM',
                        style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Pending Items ──────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 100),
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
                    const Text('Pending Items',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _darkBlue)),
                    const SizedBox(height: 14),
                    _pendingItem('3 Tasks', Icons.assignment_outlined),
                    _pendingItem('2 Reports', Icons.description_outlined),
                    _pendingItem('1 Photo', Icons.photo_outlined),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Sync Now Button ────────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 150),
              child: ElevatedButton.icon(
                onPressed: _syncing ? null : _doSync,
                icon: _syncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.sync_rounded,
                        color: Colors.white, size: 20),
                label: Text(_syncing ? 'Syncing...' : 'Sync Now',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _blue,
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─── Auto Sync Toggle ───────────────────────────────────
            FadeInUp(
              delay: const Duration(milliseconds: 190),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Auto Sync',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.grey.shade700)),
                    Switch(
                      value: _autoSync,
                      onChanged: (v) => setState(() => _autoSync = v),
                      activeColor: _blue,
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

  Widget _pendingItem(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _blue),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1A1A2E))),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded,
              color: Colors.grey, size: 18),
        ],
      ),
    );
  }
}
