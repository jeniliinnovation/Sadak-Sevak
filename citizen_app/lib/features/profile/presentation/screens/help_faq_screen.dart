import 'package:flutter/material.dart';
import 'package:sadak_sevak_citizen/core/theme/app_theme.dart';

class HelpFAQScreen extends StatefulWidget {
  const HelpFAQScreen({super.key});

  @override
  State<HelpFAQScreen> createState() => _HelpFAQScreenState();
}

class _HelpFAQScreenState extends State<HelpFAQScreen> {
  final List<Map<String, String>> _faqs = [
    {
      'question': 'How do I report a pothole?',
      'answer': 'Tap the "+" button in the center of the bottom navigation bar. Upload a photo or video of the pothole, fill in the details, specify/confirm the location on the map, and click submit.'
    },
    {
      'question': 'How long does a repair take?',
      'answer': 'Repair duration depends on the severity and category of the reported issue. High priority issues are typically addressed within 48 to 72 hours, while standard issues might take up to a week.'
    },
    {
      'question': 'Can I track the status of my report?',
      'answer': 'Yes! You can view all your reported complaints in the "My Complaints" tab. As the status updates, you will receive real-time notifications.'
    },
    {
      'question': 'What are the colored markers on the map?',
      'answer': 'Markers indicate reported issues. Green represents resolved issues, orange indicates work in progress, and blue represents newly submitted reports.'
    },
    {
      'question': 'How do I contact support?',
      'answer': 'You can reach our help desk via email at support@sadaksevak.com or call our toll-free municipal helpline at 1800-XXX-XXXX.'
    }
  ];

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
        title: const Text('Help & FAQ',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ..._faqs.map((faq) => Card(
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade100),
                  ),
                  child: ExpansionTile(
                    shape: const Border(),
                    title: Text(
                      faq['question'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondaryColor),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    expandedAlignment: Alignment.topLeft,
                    children: [
                      Text(
                        faq['answer'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600, height: 1.4),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
            const Text(
              'Need More Help?',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.secondaryColor, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.email_outlined, color: AppTheme.primaryColor, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.secondaryColor)),
                          const SizedBox(height: 2),
                          Text('Send us an email at support@sadaksevak.com', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
