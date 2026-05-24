import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  final bool isDarkMode;

  const TermsOfServiceScreen({Key? key, required this.isDarkMode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
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
              '1. Acceptance of Terms',
              'By accessing or using the Injera Platform, you agree to be bound by these Terms of Service and all applicable laws and regulations.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              '2. User Accounts',
              '• You must be at least 18 years old to use this platform\n'
                  '• You are responsible for maintaining the confidentiality of your account\n'
                  '• You agree to provide accurate and complete information\n'
                  '• You are solely responsible for all activities that occur under your account',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              '3. Intellectual Property Rights',
              'All content on this platform is protected under Copyright and Neighbouring Rights Protection Proclamation No. 872/2014. You may not copy, modify, distribute, or create derivative works without explicit permission.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              '4. User Conduct',
              'You agree not to:\n'
                  '• Violate any laws or regulations\n'
                  '• Infringe on intellectual property rights\n'
                  '• Upload malicious code or viruses\n'
                  '• Harass, abuse, or harm others\n'
                  '• Engage in fraudulent activities',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              '5. Content Ownership',
              'Users retain ownership of content they submit. However, by submitting content, you grant the platform a license to display, distribute, and promote your content.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              '6. Payments and Subscriptions',
              '• Subscription fees are billed in advance\n'
                  '• Refunds are handled according to our refund policy\n'
                  '• You authorize automatic renewal of subscriptions\n'
                  '• Price changes will be communicated in advance',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              '7. Termination',
              'We reserve the right to terminate or suspend your account for violations of these terms, fraudulent behavior, or any other reason at our sole discretion.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              '8. Limitation of Liability',
              'The platform is provided "as is" without warranties. We shall not be liable for any indirect, incidental, or consequential damages.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              '9. Governing Law',
              'These terms shall be governed by and construed in accordance with the laws of the Federal Democratic Republic of Ethiopia.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              '10. Changes to Terms',
              'We reserve the right to modify these terms at any time. Continued use of the platform constitutes acceptance of modified terms.',
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
