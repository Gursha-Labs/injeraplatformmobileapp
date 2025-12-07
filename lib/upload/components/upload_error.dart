// upload/components/upload_error.dart
import 'package:flutter/material.dart';
import 'package:injera/theme/app_colors.dart';

class UploadError extends StatelessWidget {
  final String error;
  final bool isDark;
  final VoidCallback onClear;

  const UploadError({
    super.key,
    required this.error,
    required this.isDark,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? Colors.red[900]!.withOpacity(0.2) : Colors.red[50],
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isDark ? Colors.red[800]! : Colors.red[200]!,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const Icon(Icons.error_outline, size: 16, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: TextStyle(
                  color: isDark ? Colors.red[200] : Colors.red[800],
                  fontSize: 12,
                ),
              ),
            ),
            IconButton(
              onPressed: onClear,
              icon: Icon(
                Icons.close,
                size: 14,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
