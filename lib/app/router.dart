import 'package:flutter/material.dart';

import 'package:injera/screens/advertiser/advertiser_wrapper.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name?.startsWith('/advertiser/') == true) {
      return MaterialPageRoute(
        builder: (context) => const AdvertiserWrapper(),
        settings: settings,
      );
    }
    return null;
  }
}
