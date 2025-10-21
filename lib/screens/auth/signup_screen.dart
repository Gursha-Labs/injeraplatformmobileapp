// screens/auth/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:injera/app/app.dart';
import '../home_screen.dart';
import 'components/auth_button.dart';
import 'components/auth_text_field.dart';
import 'components/social_buttons.dart';
import 'components/terms_text.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

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
          'Sign up',
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
              _buildSignupForm(),
              const SizedBox(height: 24),
              _buildSignupButton(),
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

  Widget _buildSignupForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          controller: _emailController,
          hintText: 'Email',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _usernameController,
          hintText: 'Username',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: _passwordController,
          hintText: 'Password',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
      ],
    );
  }

  Widget _buildSignupButton() {
    return AuthButton(
      text: 'Sign up',
      onPressed: _signup,
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

  void _signup() {
    // TODO: Implement signup logic when API is ready
    // For now, navigate to main app
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
      (route) => false,
    );
  }
}
