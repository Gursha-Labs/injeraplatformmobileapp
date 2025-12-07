import 'package:flutter_riverpod/legacy.dart';
import 'auth/auth_notifier.dart';
import 'auth/auth_state.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
