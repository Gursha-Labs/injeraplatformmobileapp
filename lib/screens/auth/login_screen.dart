// screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:injera/app/app.dart';
import '../home_screen.dart';
import 'components/auth_button.dart';
import 'components/auth_text_field.dart';
import 'components/social_buttons.dart';
import 'components/terms_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
          'Log in',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          controller: _emailController,
          hintText: 'Phone / Email / Username',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _passwordController,
          hintText: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        _buildForgotPassword(),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        child: const Text(
          'Forgot password?',
          style: TextStyle(
            color: Color(0xFFFE2C55),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return AuthButton(
      text: 'Log in',
      onPressed: _login,
      backgroundColor: const Color(0xFFFE2C55),
      textColor: Colors.white,
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.grey[800])),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: TextStyle(color: Colors.grey[500])),
        ),
        Expanded(child: Container(height: 1, color: Colors.grey[800])),
      ],
    );
  }

  void _login() {
    // TODO: Implement login logic when API is ready
    // For now, navigate to main app
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }
}
