import 'package:flutter/material.dart';
import 'package:injera/theme/app_colors.dart';

class CopyrightPolicyScreen extends StatelessWidget {
  final bool isDarkMode;

  const CopyrightPolicyScreen({Key? key, required this.isDarkMode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Copyright Policy',
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Based on Proclamation No. 872/2014',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Copyright and Neighbouring Rights Protection (Amendment) Proclamation',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Protected Works',
              'Under Proclamation No. 872/2014, the following works are protected:\n\n'
                  '• Literary works (books, articles, software)\n'
                  '• Musical works (compositions with or without lyrics)\n'
                  '• Artistic works (paintings, sculptures, photographs)\n'
                  '• Applied art\n'
                  '• Audiovisual works\n'
                  '• Sound recordings',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Economic Rights',
              'Copyright owners have exclusive economic rights for 50 years after the author\'s death, including:\n\n'
                  '• Reproduction rights\n'
                  '• Distribution rights\n'
                  '• Public performance rights\n'
                  '• Broadcasting rights\n'
                  '• Adaptation and translation rights',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Moral Rights',
              'Authors retain moral rights including:\n\n'
                  '• Right to claim authorship\n'
                  '• Right to prevent distortion or mutilation\n'
                  '• Right to withdraw work from circulation',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Copyright Infringement',
              'Copyright infringement occurs when protected works are used without authorization. Penalties include:\n\n'
                  '• Intentional violation: Fine of 25,000 - 50,000 Birr plus imprisonment\n'
                  '• Gross negligence violation: Fine of 5,000 - 25,000 Birr plus imprisonment',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Fair Use Exceptions',
              'Limited use of copyrighted works is permitted for:\n\n'
                  '• Private personal use (if owner of original copy)\n'
                  '• Educational purposes\n'
                  '• News reporting\n'
                  '• Critical review',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Collective Management',
              'Under Proclamation No. 872/2014, Collective Management Societies may be formed to jointly administer rights. These societies:\n\n'
                  '• Must operate on non-profit basis\n'
                  '• Require recognition from the Intellectual Property Office\n'
                  '• Deduct up to 30% of collected royalties for administration',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Reporting Infringement',
              'To report copyright infringement on our platform:\n\n'
                  '1. Submit a DMCA-style notice to copyright@injera.com\n'
                  '2. Include identification of the copyrighted work\n'
                  '3. Specify the infringing content location\n'
                  '4. Provide your contact information\n'
                  '5. Include a statement of good faith belief',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Counter-Notification',
              'If you believe content was removed in error, you may submit a counter-notification including:\n\n'
                  '• Identification of removed content\n'
                  '• Statement under penalty of perjury of good faith belief\n'
                  '• Consent to jurisdiction in Ethiopian courts',
              isDarkMode,
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Based on Federal Negarit Gazette No. 20, 14th January 2015',
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
