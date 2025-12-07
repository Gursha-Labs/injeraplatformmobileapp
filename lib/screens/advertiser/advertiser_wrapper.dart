import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart' hide AppTheme;
import 'package:injera/screens/advertiser/advertiser_analytics_screen.dart';
import 'package:injera/screens/advertiser/advertiser_dashboard_screen.dart';
import 'package:injera/screens/advertiser/advertiser_profile_screen.dart';
import 'package:injera/screens/advertiser/advertiser_upload_screen.dart';
import 'package:injera/theme/app_theme.dart';
import 'advertiser_main_screen.dart';

class AdvertiserWrapper extends ConsumerWidget {
  const AdvertiserWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Injera Advertiser',
      theme: themeState.isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const AdvertiserMainScreen(),
      routes: _buildRoutes(),
    );
  }

  Map<String, WidgetBuilder> _buildRoutes() {
    return {
      '/advertiser/dashboard': (context) => const AdvertiserDashboardScreen(),
      '/advertiser/upload': (context) => const AdvertiserUploadScreen(),
      '/advertiser/profile': (context) => const AdvertiserProfileScreen(),
      '/advertiser/analytics': (context) => const AdvertiserAnalyticsScreen(),
    };
  }
}
