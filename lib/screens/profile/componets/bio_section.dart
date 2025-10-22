// screens/profile/components/bio_section.dart
import 'package:flutter/material.dart';

class BioSection extends StatelessWidget {
  const BioSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Digital creator 🎬\n✨ Creating awesome content\n📍 Los Angeles, CA',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.link, color: Colors.grey[400], size: 16),
              const SizedBox(width: 4),
              Text(
                'instagram.com/username',
                style: TextStyle(color: const Color(0xFFFE2C55), fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.people, color: Colors.grey[400], size: 16),
              const SizedBox(width: 4),
              Text(
                '12 mutual followers',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
