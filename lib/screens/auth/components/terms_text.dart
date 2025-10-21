// screens/auth/components/terms_text.dart
import 'package:flutter/material.dart';

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        'By continuing, you agree to our Terms of Service and acknowledge that you have read our Privacy Policy to learn how we collect, use and share your data.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
      ),
    );
  }
}
