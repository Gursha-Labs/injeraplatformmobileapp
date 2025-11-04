// screens/auth/otp_verification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/app/app.dart';
import 'package:injera/providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _showSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    _setupOtpFields();
  }

  void _setupOtpFields() {
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (!_focusNodes[i].hasFocus && _otpControllers[i].text.isEmpty) {
          if (i > 0) {
            _focusNodes[i - 1].requestFocus();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

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
          'Verify Email',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authProvider);

              // Show success message and navigate when verified
              if (authState.status == AuthStatus.authenticated &&
                  !_showSuccessMessage) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  setState(() {
                    _showSuccessMessage = true;
                  });
                  _showSuccessAndNavigate(context);
                });
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(authState),
                  const SizedBox(height: 32),
                  _buildOtpFields(),
                  const SizedBox(height: 32),
                  _buildVerifyButton(ref, authState),
                  const SizedBox(height: 20),
                  _buildResendCode(),
                  if (authState.error != null) ...[
                    const SizedBox(height: 20),
                    _buildErrorText(authState.error!),
                  ],
                  if (_showSuccessMessage) ...[
                    const SizedBox(height: 20),
                    _buildSuccessText(),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP Code',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit code to ${authState.user?.email}',
          style: TextStyle(color: Colors.grey[400], fontSize: 16),
        ),
        if (authState.message != null && !_showSuccessMessage) ...[
          const SizedBox(height: 8),
          Text(
            authState.message!,
            style: TextStyle(color: Colors.green[400], fontSize: 14),
          ),
        ],
      ],
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 50,
          height: 50,
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[700]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFFE2C55)),
              ),
            ),
            onChanged: (value) {
              if (value.length == 1 && index < 5) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildVerifyButton(WidgetRef ref, AuthState authState) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: authState.isLoading ? null : () => _verifyOtp(ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFE2C55),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            : const Text(
                'Verify',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildResendCode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive code? ",
          style: TextStyle(color: Colors.grey[400]),
        ),
        TextButton(
          onPressed: () {
            // TODO: Implement resend OTP
          },
          child: const Text(
            'Resend',
            style: TextStyle(
              color: Color(0xFFFE2C55),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorText(String error) {
    // Clean up the error message for better user experience
    String displayError = error;
    if (error.contains('Invalid JSON token') || error.contains('json')) {
      displayError =
          'Invalid verification code. Please check the code and try again.';
    } else if (error.contains('Connection') ||
        error.contains('Socket') ||
        error.contains('Network')) {
      displayError =
          'Network error. Please check your connection and try again.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[300], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(displayError, style: TextStyle(color: Colors.red[300])),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[900]!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[300], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Email verified successfully! Redirecting to home screen...',
              style: TextStyle(color: Colors.green[300]),
            ),
          ),
        ],
      ),
    );
  }

  void _verifyOtp(WidgetRef ref) {
    final otp = _otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter 6-digit OTP code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(authProvider.notifier).verifyOtp(otp);
  }

  void _showSuccessAndNavigate(BuildContext context) {
    // Show success message for 2 seconds then navigate
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    });
  }
}
