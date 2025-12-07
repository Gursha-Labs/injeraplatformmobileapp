import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/app/auth_wrapper.dart';
import 'package:injera/app/router.dart';
import 'package:injera/providers/theme_provider.dart' hide AppTheme;
import 'package:injera/theme/app_theme.dart';

class InjeraApp extends ConsumerWidget {
  const InjeraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Injera',
      theme: themeState.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
