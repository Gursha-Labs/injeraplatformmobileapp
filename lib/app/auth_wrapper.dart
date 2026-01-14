import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/models/user_models.dart' hide AppTheme;
import 'package:injera/providers/auth/auth_state.dart';
import 'package:injera/screens/auth/login_screen.dart';
import 'package:injera/providers/auth_provider.dart';
import 'package:injera/screens/auth/verification_screen.dart';
import 'package:injera/screens/main_app/main_screen.dart';
import 'package:injera/screens/advertiser/advertiser_wrapper.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return _buildContentBasedOnAuthState(authState);
  }

  Widget _buildContentBasedOnAuthState(AuthState authState) {
    final next = authState.user?.email!;
    // Show LoginScreen while checking auth status or if unauthenticated
    if (authState.status == AuthStatus.loading) {
      return LoginScreen(isCheckingAuthStatus: true);
    }

    switch (authState.status) {
      case AuthStatus.authenticated:
        if (authState.user?.type == UserType.advertiser) {
          return const AdvertiserWrapper();
        } else {
          return const MainScreen();
        }
      case AuthStatus.verificationRequired:
        return VerificationScreen(email: next!);
      case AuthStatus.unauthenticated:
      default:
        return const LoginScreen();
    }
  }
}
