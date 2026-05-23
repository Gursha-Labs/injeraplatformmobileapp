import 'package:flutter/material.dart';
import 'package:injera/models/subscription_models.dart';
import 'package:injera/theme/app_theme.dart';

class SubscriptionCard extends StatelessWidget {
  final Subscription subscription;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCurrentSubscription;

  const SubscriptionCard({
    Key? key,
    required this.subscription,
    required this.isSelected,
    required this.onTap,
    this.isCurrentSubscription = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : isDark
              ? Colors.grey[900]
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : isDark
                ? Colors.grey[800]!
                : Colors.grey[200]!,
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            else
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscription.name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : isDark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (subscription.description != null)
                              Text(
                                subscription.description!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.8)
                                      : isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isCurrentSubscription)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${subscription.currency} ${subscription.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : isDark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '/ ${subscription.durationText.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? Colors.white.withOpacity(0.7)
                                : isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Features
                  _buildFeatureRow(
                    context,
                    Icons.video_library_outlined,
                    '${subscription.videoUploadLimitText} upload limit',
                    isSelected,
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureRow(
                    context,
                    Icons.timer_outlined,
                    'Max ${subscription.videoDurationText} per video',
                    isSelected,
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureRow(
                    context,
                    Icons.verified_outlined,
                    'Priority support',
                    isSelected,
                    isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildFeatureRow(
                    context,
                    Icons.analytics_outlined,
                    'Advanced analytics',
                    isSelected,
                    isDark,
                  ),
                  const SizedBox(height: 24),

                  // Subscribe Button
                  if (!isCurrentSubscription)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? Colors.white
                              : const Color(0xFFEF4444),
                          foregroundColor: isSelected
                              ? const Color(0xFFEF4444)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Subscribe Now',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  if (isCurrentSubscription)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isSelected
                              ? Colors.white
                              : Colors.red,
                          side: BorderSide(
                            color: isSelected ? Colors.white : Colors.red,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Cancel Subscription',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 16,
                right: 16,
                child: Icon(Icons.check_circle, color: Colors.white, size: 28),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureRow(
    BuildContext context,
    IconData icon,
    String text,
    bool isSelected,
    bool isDark,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isSelected
              ? Colors.white.withOpacity(0.8)
              : isDark
              ? Colors.grey[400]
              : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: isSelected
                ? Colors.white.withOpacity(0.8)
                : isDark
                ? Colors.grey[400]
                : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? '
          'You will lose access to premium features at the end of your billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Plan'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onTap(); // This will trigger cancellation
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Anyway'),
          ),
        ],
      ),
    );
  }
}
