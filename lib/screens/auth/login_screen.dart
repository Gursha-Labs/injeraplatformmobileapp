import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/auth_provider.dart';
import 'components/auth_button.dart';
import 'components/auth_text_field.dart';
import 'components/social_buttons.dart';
import 'components/terms_text.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
              _buildLoginButton(),
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
            hintText: 'Email',
            icon: Icons.person_outline,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or username';
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
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
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

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          _showForgotPasswordDialog();
        },
        child: const Text(
          'Forgot your password?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);

        return Column(
          children: [
            if (authState.error != null) ...[
              _buildErrorText(authState.error!),
              const SizedBox(height: 16),
            ],
            AuthButton(
              text: 'Login',
              onPressed: authState.isLoading ? null : _login,
              backgroundColor: Colors.white,
              textColor: Colors.black,
              isLoading: authState.isLoading,
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorText(String error) {
    String displayError = error;

    if (error.contains('Invalid credentials') ||
        error.contains('invalid') ||
        error.contains('incorrect')) {
      displayError = 'Invalid email/username or password. Please try again.';
    } else if (error.contains('Network') ||
        error.contains('Connection') ||
        error.contains('Socket') ||
        error.contains('timeout')) {
      displayError =
          'Network error. Please check your connection and try again.';
    } else if (error.contains('Unexpected response format')) {
      displayError = 'Server error. Please try again later.';
    } else if (error.contains('user not found') ||
        error.contains('User not found')) {
      displayError =
          'Account not found. Please check your credentials or sign up for a new account.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayError,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey[700])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: TextStyle(color: Colors.grey[400])),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey[700])),
      ],
    );
  }

  Widget _buildSignupRedirect() {
    return Center(
      child: GestureDetector(
        onTap: _navigateToSignup,
        child: RichText(
          text: TextSpan(
            text: "Don't have an account? ",
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
            children: const [
              TextSpan(
                text: 'Sign up',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final login = _loginController.text.trim();
    final password = _passwordController.text.trim();

    final ref = ProviderScope.containerOf(context);

    try {
      await ref.read(authProvider.notifier).login(login, password);
      final authState = ref.read(authProvider);

      if (authState.isAuthenticated) {
        _showSuccessMessage('Login successful!');
      } else if (authState.requiresVerification) {
        _showInfoMessage('Please check your email for verification code');
      }
    } catch (e) {
      print('Login screen error: $e');
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Password reset functionality will be implemented soon.',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
