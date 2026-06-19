import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';

class AboutSadakSevakScreen extends StatelessWidget {
  const AboutSadakSevakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppTheme.secondaryColor),
        ),
        title: const Text('About Sadak-Sevak',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              height: 100,
              width: 100,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.construction_rounded, color: Colors.white, size: 55),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sadak-Sevak',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
            ),
            Text(
              'Version 1.0.0 (Build 2026)',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
            const SizedBox(height: 30),
            const Text(
              'Sadak-Sevak is a next-generation civic platform dedicated to building safer, smoother, and more reliable roads. We bridge the gap between citizens, contractors, and local government departments by enabling transparent reporting, tracking, and fast resolution of public road infrastructure issues.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.secondaryColor, height: 1.5),
            ),
            const SizedBox(height: 40),
            _buildInfoRow('Developed By', 'Sadak-Sevak Dev Team'),
            _buildInfoRow('Contact Email', 'contact@sadaksevak.com'),
            _buildInfoRow('Website', 'www.sadaksevak.com'),
            _buildInfoRow('Legal & Terms', 'View Terms of Service'),
            const SizedBox(height: 40),
            Text(
              '© 2026 Sadak-Sevak Inc. All rights reserved.',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500)),
              Text(value, style: const TextStyle(color: AppTheme.secondaryColor, fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE8F2EC), height: 1),
        ],
      ),
    );
  }
}
