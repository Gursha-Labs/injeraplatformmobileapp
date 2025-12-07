import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/auth/auth_state.dart';
import 'package:injera/providers/auth_provider.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
  }

  void _startCooldownTimer() {
    _resendCooldown = 60; // 60 seconds cooldown
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

  Future<void> _resendOtp() async {
    if (_resendCooldown > 0 || _isResending) return;

    setState(() => _isResending = true);

    try {
      final result = await ref
          .read(authProvider.notifier)
          .resendVerification(widget.email);

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('New OTP sent successfully!'),
            backgroundColor: Colors.black,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        _startCooldownTimer(); // Restart cooldown timer
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Failed to send OTP'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend OTP: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } finally {
      setState(() => _isResending = false);
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Verify Email',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Header Section
                _buildHeaderSection(),

                const SizedBox(height: 48),

                // OTP Input Section
                _buildOtpInputSection(authState),

                const SizedBox(height: 32),

                // Action Button
                _buildVerifyButton(authState),

                const SizedBox(height: 24),

                // Resend OTP Section
                _buildResendSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black12, width: 1.5),
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            color: Colors.black,
            size: 24,
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Email Verification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 12),

        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
              height: 1.5,
            ),
            children: [
              const TextSpan(text: 'We sent a verification code to '),
              TextSpan(
                text: widget.email,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(
                text: '. Please enter it below to verify your email address.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOtpInputSection(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verification Code',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: authState.error != null ? Colors.black : Colors.black26,
              width: authState.error != null ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _otpController,
            focusNode: _otpFocusNode,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
              hintText: 'Enter 6-digit code',
              hintStyle: TextStyle(
                color: Colors.black38,
                fontWeight: FontWeight.w400,
              ),
            ),
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _verifyOtp(),
          ),
        ),

        if (authState.error != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.black, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authState.error!,
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerifyButton(AuthState authState) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : () => _verifyOtp(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.black38,
        ),
        child: authState.isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Verify Email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Column(
      children: [
        const Divider(color: Colors.black12),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Didn't receive the code? ",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            if (_isResending)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            else if (_resendCooldown > 0)
              Text(
                'Resend in $_resendCooldown',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              GestureDetector(
                onTap: _resendOtp,
                child: const Text(
                  'Resend Code',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _verifyOtp() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    final result = await ref
        .read(authProvider.notifier)
        .verifyOtp(_otpController.text);

    if (result.success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Email verified successfully!'),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
}
