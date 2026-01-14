// upload/components/upload_stats.dart
import 'package:flutter/material.dart';

class UploadStats extends StatelessWidget {
  final bool isDark;

  const UploadStats({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white30 : Colors.black12,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMANCE METRICS',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estimated performance based on similar content',
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard(
          title: 'REACH',
          value: '15-20K',
          subtitle: 'Estimated Views',
          icon: Icons.visibility,
        ),
        Container(
          height: 40,
          width: 1,
          color: isDark ? Colors.white24 : Colors.black12,
        ),
        _buildStatCard(
          title: 'ENGAGEMENT',
          value: '8.5%',
          subtitle: 'Expected Rate',
          icon: Icons.trending_up,
        ),
        Container(
          height: 40,
          width: 1,
          color: isDark ? Colors.white24 : Colors.black12,
        ),
        _buildStatCard(
          title: 'CONVERSION',
          value: '3.2%',
          subtitle: 'Potential Rate',
          icon: Icons.shopping_cart,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white60 : Colors.black45,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
