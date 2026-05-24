import 'package:flutter/material.dart';
import 'package:injera/theme/app_colors.dart';

class GamblingPolicyScreen extends StatelessWidget {
  final bool isDarkMode;

  const GamblingPolicyScreen({Key? key, required this.isDarkMode})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Gambling Policy',
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
                    'Based on Directive No. 856/2014',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sports Betting Lottery Licensing Directive',
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
              'Age Restriction',
              'In compliance with Directive No. 856/2014 Article 10:\n\n'
                  '• You must be 21 years or older to participate in any betting activities\n'
                  '• Age verification is required before account activation\n'
                  '• Providing false age information is a violation of terms',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Licensing Requirements',
              'Under the directive, all betting operators must:\n\n'
                  '• Obtain a valid license from the National Lottery Administration\n'
                  '• Provide a bank guarantee of 1,500,000 Birr\n'
                  '• Maintain proper financial records\n'
                  '• Submit regular reports to authorities',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Prohibited Locations',
              'According to Article 16 of the directive, betting is prohibited:\n\n'
                  '• Within 500 meters of religious institutions\n'
                  '• Within 500 meters of educational institutions\n'
                  '• In grocery stores, bars, and restaurants\n'
                  '• In unauthorized locations outside licensed branches',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Tax and Commission',
              'Financial requirements under the directive:\n\n'
                  '• 15% commission on gross revenue payable to National Lottery Administration\n'
                  '• 15% income tax on winnings exceeding 1,000 Birr\n'
                  '• 0.5% of gross revenue for social development purposes\n'
                  '• Payments must be made by the 15th of each month',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Maximum Payouts',
              'Under Article 9 of the directive:\n\n'
                  '• Maximum payout per bet is 1,000,000 Birr\n'
                  '• Winnings must be paid within 15 days of claim\n'
                  '• Valid receipts are required for all payouts',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Student Protection',
              'To protect students, the directive prohibits:\n\n'
                  '• Students in uniform from participating in betting\n'
                  '• Betting locations near schools\n'
                  '• Advertising targeting minors',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Responsible Gambling',
              'Our commitment to responsible gambling:\n\n'
                  '• Self-exclusion options available\n'
                  '• Deposit limits can be set\n'
                  '• Reality checks and time limits\n'
                  '• Links to gambling addiction support resources\n'
                  '• No credit extensions for betting',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Penalties for Violations',
              'Under the directive, violations may result in:\n\n'
                  '• Fines up to 50,000 Birr\n'
                  '• License suspension or revocation\n'
                  '• Criminal prosecution for unlicensed operations\n'
                  '• 20% late payment penalty for overdue commissions',
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Dispute Resolution',
              'Any disputes regarding bets or winnings:\n\n'
                  '• Must be reported within 30 days\n'
                  '• Will be investigated by the National Lottery Administration\n'
                  '• Appeals may be made to Federal High Court',
              isDarkMode,
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Based on National Lottery Administration Directive\nEffective Date: 17th September, 2015',
                textAlign: TextAlign.center,
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
