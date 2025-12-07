// screens/games_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Games',
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.iconDark : AppColors.iconLight,
        ),
      ),
      body: Center(
        child: Text(
          'Games Coming Soon!',
          style: TextStyle(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
