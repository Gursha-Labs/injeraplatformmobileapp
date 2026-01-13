import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/auth/auth_state.dart';
import 'package:injera/providers/auth_provider.dart';
import 'package:injera/screens/auth/forgot_password_screen.dart';
import 'package:injera/screens/auth/signup_screen.dart';
import 'components/auth_button.dart';
import 'components/auth_text_field.dart';
import 'components/social_buttons.dart';
import 'components/terms_text.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final bool isCheckingAuthStatus;

  const LoginScreen({super.key, this.isCheckingAuthStatus = false});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer? _errorTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only reset state if we're not checking auth status
      if (!widget.isCheckingAuthStatus) {
        final authState = ref.read(authProvider);

        // If there's an existing error, start timer to clear it after 5 seconds
        if (authState.error != null && authState.error!.isNotEmpty) {
          _startErrorTimer();
        } else {
          // Otherwise, reset state to clear any lingering messages
          ref.read(authProvider.notifier).resetState();
        }
      }
    });
  }

  void _startErrorTimer() {
    // Cancel any existing timer
    _errorTimer?.cancel();

    // Start new 5-second timer
    _errorTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        ref.read(authProvider.notifier).resetState();
      }
    });
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _errorTimer?.cancel(); // Don't forget to cancel the timer!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Log in',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              _buildLoginForm(),

              const SizedBox(height: 24),

              // Show checking status message if we're checking auth
              _buildStatusFeedback(authState),

              const SizedBox(height: 24),

              AuthButton(
                text: 'Login',
                onPressed: authState.isLoading || widget.isCheckingAuthStatus
                    ? null
                    : _login,
                backgroundColor: Colors.white,
                textColor: Colors.black,
                isLoading: authState.isLoading || widget.isCheckingAuthStatus,
              ),

              const SizedBox(height: 32),
              _buildDivider(),
              const SizedBox(height: 32),
              const SocialButtons(),
              const SizedBox(height: 32),
              const TermsText(),
              const SizedBox(height: 20),
              _buildSignupRedirect(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            controller: _loginController,
            hintText: 'Email or Username',
            icon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            // Enhanced validation
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email or username';
              }

              // If it looks like an email (contains @), validate email format
              final trimmedValue = value.trim();
              if (trimmedValue.contains('@')) {
                // First check for spaces
                if (trimmedValue.contains(' ')) {
                  return 'Email cannot contain spaces';
                }

                // Check for single @ symbol
                final atCount = trimmedValue.split('@').length - 1;
                if (atCount != 1) {
                  return 'Email must contain exactly one @ symbol';
                }

                // Check doesn't start or end with @
                if (trimmedValue.startsWith('@') ||
                    trimmedValue.endsWith('@')) {
                  return 'Invalid email format';
                }

                // Split into local part and domain
                final parts = trimmedValue.split('@');
                final localPart = parts[0];
                final domain = parts[1];

                // Check local part is not empty
                if (localPart.isEmpty) {
                  return 'Invalid email - missing local part before @';
                }

                // Check domain is not empty
                if (domain.isEmpty) {
                  return 'Invalid email - missing domain after @';
                }

                // Check domain has at least one dot
                if (!domain.contains('.')) {
                  return 'Invalid email - domain must contain a dot (.)';
                }

                // Check domain doesn't start or end with dot
                if (domain.startsWith('.') || domain.endsWith('.')) {
                  return 'Invalid email - domain cannot start or end with dot';
                }

                // Enhanced email validation with stricter domain checking
                final emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );

                if (!emailRegex.hasMatch(trimmedValue)) {
                  return 'Please enter a valid email address (e.g., user@example.com)';
                }

                // Additional domain validation
                final domainParts = domain.split('.');
                final tld =
                    domainParts.last; // Top-level domain (com, org, net, etc.)

                // Check TLD length (usually 2+ characters)
                if (tld.length < 2) {
                  return 'Invalid email - domain extension too short';
                }

                // Check if TLD contains only letters
                if (!RegExp(r'^[a-zA-Z]+$').hasMatch(tld)) {
                  return 'Invalid email - domain extension must contain only letters';
                }
              } else {
                // Username validation
                if (trimmedValue.length < 3) {
                  return 'Username must be at least 3 characters';
                }

                if (trimmedValue.length > 30) {
                  return 'Username must be less than 30 characters';
                }

                // Check for special characters in username
                final usernameRegex = RegExp(r'^[a-zA-Z0-9_.-]+$');
                if (!usernameRegex.hasMatch(trimmedValue)) {
                  return 'Username can only contain letters, numbers, ., _, and -';
                }
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            hintText: 'Password',
            icon: Icons.lock_outline,
            isPassword: true,
            keyboardType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }

              // Client-side password validation
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }

              if (value.length > 50) {
                return 'Password is too long';
              }

              // Check for spaces
              if (value.contains(' ')) {
                return 'Password cannot contain spaces';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          _buildForgotPassword(),
        ],
      ),
    );
  }

  // --- NEW PROFESSIONAL ERROR DISPLAY ---
  // This widget renders the red error box or green success box inline
  Widget _buildStatusFeedback(AuthState authState) {
    // Case 1: Error
    if (authState.error != null && authState.error!.isNotEmpty) {
      print('Error displayed: ${authState.error}');
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[900]!.withOpacity(0.2), // Dark red background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[700]!), // Visible red border
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[300], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                authState.error!,
                style: TextStyle(
                  color: Colors.red[100],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    // Case 3: Empty (Hidden)
    return const SizedBox.shrink();
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: widget.isCheckingAuthStatus
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
        child: const Text(
          'Forgot your password?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey[700]!)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: TextStyle(color: Colors.grey[400])),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey[700]!)),
      ],
    );
  }

  Widget _buildSignupRedirect() {
    return Center(
      child: GestureDetector(
        onTap: widget.isCheckingAuthStatus ? null : _navigateToSignup,
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(
              color: widget.isCheckingAuthStatus
                  ? Colors.grey[600]!
                  : Colors.grey[400]!,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: 'Sign up',
                style: TextStyle(
                  color: widget.isCheckingAuthStatus
                      ? Colors.grey[600]!
                      : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    // Cancel any existing error timer when user tries to login again
    _errorTimer?.cancel();

    // Clear any existing errors when starting new login attempt
    ref.read(authProvider.notifier).clearError();

    // 1. Validate Form (Client-side check)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    FocusScope.of(context).unfocus(); // Close keyboard

    // 2. Perform Login
    final result = await ref.read(authProvider.notifier).login(login, password);

    if (result.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // If login failed, start timer to clear error after 5 seconds
      _startErrorTimer();
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }
}
