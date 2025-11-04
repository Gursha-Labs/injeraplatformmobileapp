// screens/auth/components/social_buttons.dart
import 'package:flutter/material.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        _buildSocialButton(
          iconPath: 'assets/icons/google.png',
          text: 'Continue with Google',
          backgroundColor: Colors.white,
          textColor: Colors.black,
          onPressed: () => _handleSocialLogin('google'),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String iconPath,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
          side: backgroundColor == Colors.white
              ? BorderSide(color: Colors.grey[300]!)
              : BorderSide.none,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 20,
              height: 20,
              color: _getIconColor(backgroundColor),
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color? _getIconColor(Color backgroundColor) {
    if (backgroundColor == Colors.white) {
      return null; // Use original icon color
    } else if (backgroundColor == Colors.black) {
      return Colors.white;
    }
    return Colors.white; // For colored backgrounds, use white icons
  }

  void _handleSocialLogin(String provider) {
    // TODO: Replace with actual social login implementation
    print('$provider login pressed');

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 2), () {
      // Close loading dialog
      // For now, just print the provider
      // In real implementation, you would:
      // 1. Authenticate with the social provider
      // 2. Send token to your backend
      // 3. Navigate to main app on success
    });
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFFE2C55)),
              SizedBox(height: 16),
              Text('Signing in...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
