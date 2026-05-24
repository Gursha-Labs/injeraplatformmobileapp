import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final bool isDarkMode;

  const PrivacyPolicyScreen({Key? key, required this.isDarkMode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Information We Collect',
              'We collect information that you provide directly to us, including:\n\n'
                  '• Account information (name, email, phone number)\n'
                  '• Profile information\n'
                  '• Payment information\n'
                  '• Usage data and analytics\n'
                  '• Device information',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'How We Use Your Information',
              'Your information is used for:\n\n'
                  '• Providing and maintaining our services\n'
                  '• Processing transactions\n'
                  '• Sending important notifications\n'
                  '• Improving user experience\n'
                  '• Legal compliance',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Data Protection',
              'We implement appropriate technical and organizational measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction, as required under Ethiopian law.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Data Sharing',
              'We do not sell your personal information. We may share data with:\n\n'
                  '• Service providers\n'
                  '• Legal authorities when required\n'
                  '• Business partners with your consent',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Your Rights',
              'Under Ethiopian law, you have the right to:\n\n'
                  '• Access your personal data\n'
                  '• Correct inaccurate data\n'
                  '• Request deletion of your data\n'
                  '• Opt-out of marketing communications\n'
                  '• Data portability',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Cookies and Tracking',
              'We use cookies and similar technologies to enhance your experience, analyze usage, and personalize content. You can control cookie preferences through your browser settings.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Data Retention',
              'We retain your personal data for as long as necessary to provide services and comply with legal obligations. You may request deletion of your data at any time.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Children\'s Privacy',
              'Our services are not directed to individuals under 18. We do not knowingly collect personal information from minors.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'International Data Transfers',
              'Your information may be transferred to and processed in countries other than Ethiopia. We ensure appropriate safeguards are in place.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Contact Us',
              'For privacy-related questions or concerns, contact our Data Protection Officer at:\n\n'
                  'Email: privacy@injera.com\n'
                  'Address: Addis Ababa, Ethiopia',
              isDarkMode,
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Last Updated: January 2024',
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
