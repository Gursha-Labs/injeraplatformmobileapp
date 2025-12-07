import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/auth/auth_state.dart';
import 'package:injera/providers/auth_provider.dart';
import 'components/auth_button.dart';
import 'components/auth_text_field.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordResetSuccess = false;
  bool _isNavigating = false;
  int _resendCooldown = 0;
  bool _isResending = false;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).resetState();
    });
    _startCooldownTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldownTimer() {
    // Start with 60 seconds cooldown
    _resendCooldown = 60;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown > 0) {
        setState(() {
          _resendCooldown--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Listen for successful password reset
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!_passwordResetSuccess &&
          !next.isLoading &&
          next.message?.contains('successfully') == true) {
        _handleSuccessfulReset();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reset Password',
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
              _buildResetForm(),
              const SizedBox(height: 16),
              _buildResendSection(),
              const SizedBox(height: 24),
              _buildResetButton(authState),
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
          'Enter the OTP sent to ${widget.email} and your new password',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AuthTextField(
            controller: _otpController,
            hintText: 'OTP Code',
            icon: Icons.sms_outlined,
            keyboardType: TextInputType.number,

            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the OTP code';
              }
              if (value.length != 6) {
                return 'OTP must be 6 digits';
              }
              if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                return 'Please enter a valid 6-digit OTP';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _passwordController,
            hintText: 'New Password',
            icon: Icons.lock_outline,
            isPassword: true,
            keyboardType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AuthTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm New Password',
            icon: Icons.lock_outline,
            isPassword: true,
            keyboardType: TextInputType.visiblePassword,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
        if (_resendCooldown > 0)
          Text(
            'Resend in $_resendCooldown s',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          )
        else
          GestureDetector(
            onTap: _isResending ? null : _resendOtp,
            child: _isResending
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Resend Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
          ),
      ],
    );
  }

  Widget _buildResetButton(AuthState authState) {
    return Column(
      children: [
        if (authState.error != null) ...[
          _buildMessageText(authState.error!, isError: true),
          const SizedBox(height: 16),
        ],
        if (authState.message != null && !_passwordResetSuccess) ...[
          _buildMessageText(authState.message!, isError: false),
          const SizedBox(height: 16),
        ],
        if (_passwordResetSuccess) ...[
          _buildMessageText(
            'Password reset successfully! Redirecting to login...',
            isError: false,
          ),
          const SizedBox(height: 16),
        ],
        AuthButton(
          text: 'Reset Password',
          onPressed: (authState.isLoading || _isNavigating)
              ? null
              : _resetPassword,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          isLoading: authState.isLoading || _isNavigating,
        ),
      ],
    );
  }

  Widget _buildMessageText(String text, {bool isError = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red[900]!.withOpacity(0.3)
            : Colors.green[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isError ? Colors.red : Colors.green),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle,
            color: isError ? Colors.red[300] : Colors.green[300],
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isError ? Colors.red[300] : Colors.green[300],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final otp = _otpController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Double check password match
    if (password != confirmPassword) {
      ref.read(authProvider.notifier).state = AuthState(
        status: AuthStatus.unauthenticated,
        error: 'Passwords do not match',
      );
      return;
    }

    FocusScope.of(context).unfocus();

    final result = await ref
        .read(authProvider.notifier)
        .resetPassword(
          email: widget.email,
          otp: otp,
          password: password,
          passwordConfirmation: confirmPassword,
        );

    if (result.success) {
      // The navigation will be handled by the ref.listen above
      setState(() {
        _passwordResetSuccess = true;
      });
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
    });

    final result = await ref
        .read(authProvider.notifier)
        .forgotPassword(widget.email);

    setState(() {
      _isResending = false;
    });

    if (result.success) {
      // Start cooldown timer
      _startCooldownTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? 'New OTP sent successfully!'),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            textColor: Colors.black,
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Failed to resend OTP'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            textColor: Colors.white,
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  void _handleSuccessfulReset() {
    if (_isNavigating) return;

    _isNavigating = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to login after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            // Use Navigator.pop until we reach the first route (login screen)
            Navigator.popUntil(context, (route) {
              return route.isFirst;
            });
          }
        });
      }
    });
  }
}
