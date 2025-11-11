// screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/auth_provider.dart';
import 'components/auth_button.dart';
import 'components/auth_text_field.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _shouldRedirect = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildEmailForm(),
              const SizedBox(height: 24),
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reset Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we\'ll send you an OTP to reset your password.',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthTextField(
            controller: _emailController,
            hintText: 'Email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authProvider);

        // Auto-redirect when OTP is successfully sent
        if (authState.message != null &&
            !authState.isLoading &&
            !_shouldRedirect) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _shouldRedirect = true;
            });
            _redirectToResetScreen();
          });
        }

        return Column(
          children: [
            if (authState.error != null) ...[
              _buildErrorText(authState.error!),
              const SizedBox(height: 16),
            ],
            if (authState.message != null && authState.isLoading) ...[
              _buildSuccessText(authState.message!),
              const SizedBox(height: 16),
            ],
            AuthButton(
              text: 'Send OTP',
              onPressed: authState.isLoading ? null : _sendOtp,
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

    if (error.contains('Network') ||
        error.contains('Connection') ||
        error.contains('Socket')) {
      displayError =
          'Network error. Please check your connection and try again.';
    } else if (error.contains('user not found') ||
        error.contains('User not found')) {
      displayError = 'No account found with this email address.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              displayError,
              style: TextStyle(color: Colors.red[300], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessText(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[300], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.green[300], fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim();
    final ref = ProviderScope.containerOf(context);

    await ref.read(authProvider.notifier).forgotPassword(email);
  }

  void _redirectToResetScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ResetPasswordScreen(email: _emailController.text.trim()),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
