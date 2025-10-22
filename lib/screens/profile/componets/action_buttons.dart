// screens/profile/components/action_buttons.dart
import 'package:flutter/material.dart';
import 'edit_profile_button.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Expanded(child: EditProfileButton()),
          const SizedBox(width: 8),
          _buildFollowButton(),
          const SizedBox(width: 8),
          _buildMessageButton(),
        ],
      ),
    );
  }

  Widget _buildFollowButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFFE2C55),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.person_add, color: Colors.white, size: 20),
    );
  }

  Widget _buildMessageButton() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(
        Icons.chat_bubble_outline,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
