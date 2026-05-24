import 'package:flutter/material.dart';

class SecurityPolicyScreen extends StatelessWidget {
  final bool isDarkMode;

  const SecurityPolicyScreen({Key? key, required this.isDarkMode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Security Policy',
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
              'Our Security Commitment',
              'We are committed to protecting your data and maintaining the highest security standards. Our security measures are regularly updated to address emerging threats.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Data Encryption',
              '• All data transmitted between your device and our servers is encrypted using TLS 1.3\n'
                  '• Sensitive data is encrypted at rest using AES-256 encryption\n'
                  '• Payment information is tokenized and never stored in plain text',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Access Control',
              '• Multi-factor authentication available for all accounts\n'
                  '• Role-based access control for employees\n'
                  '• Regular access reviews and audits\n'
                  '• Principle of least privilege enforced',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Monitoring and Detection',
              '• 24/7 security monitoring\n'
                  '• Real-time threat detection systems\n'
                  '• Automated vulnerability scanning\n'
                  '• Regular penetration testing',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Incident Response',
              'We maintain a comprehensive incident response plan including:\n\n'
                  '• Immediate containment procedures\n'
                  '• Forensic investigation capabilities\n'
                  '• Regulatory notification protocols\n'
                  '• User notification within 72 hours of breach discovery',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Secure Development',
              '• Security review in all development phases\n'
                  '• Regular dependency scanning\n'
                  '• Code signing and verification\n'
                  '• Secure coding training for developers',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Third-Party Security',
              'All third-party service providers undergo security assessment and must comply with our security standards, including:\n\n'
                  '• SOC 2 certification\n'
                  '• GDPR compliance where applicable\n'
                  '• Regular security audits',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Password Security',
              '• Minimum password length: 8 characters\n'
                  '• Password complexity requirements enforced\n'
                  '• Password hashing using bcrypt\n'
                  '• Automatic password expiration after 90 days\n'
                  '• Breached password detection',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Reporting Vulnerabilities',
              'If you discover a security vulnerability, please report it to security@injera.com. We offer bug bounties for qualifying reports.',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Compliance',
              'We comply with:\n\n'
                  '• Ethiopian data protection laws\n'
                  '• Copyright and Neighbouring Rights Protection Proclamation No. 872/2014\n'
                  '• Industry best practices (ISO 27001)',
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
