import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/screens/game/components/game_card.dart';
import 'package:injera/screens/game/games/color_match_game.dart';
import 'package:injera/screens/game/games/match_game.dart';
import 'package:injera/screens/game/games/quiz_game.dart';
import 'package:injera/screens/game/games/spin_game.dart';
import 'package:injera/screens/game/games/tap_game.dart';

import 'package:injera/theme/app_colors.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  // Replace the quiz game with color match game
  final List<GameItem> _games = [
    GameItem(
      id: 'spin',
      title: 'Spin Wheel',
      description: 'Spin to win amazing rewards',
      icon: Icons.casino_rounded,
      color: Colors.black,
      points: 100,
      time: '1 min',
      gradient: [Colors.black, Colors.grey.shade900],
    ),
    GameItem(
      id: 'color-match', // Changed from 'quiz'
      title: 'Color Match',
      description: 'Find matching colors quickly',
      icon: Icons.color_lens_rounded,
      color: Colors.white,
      points: 150,
      time: '2 min',
      gradient: [Colors.white, Colors.grey.shade300],
    ),
    GameItem(
      id: 'match',
      title: 'Match Pairs',
      description: 'Find matching pairs quickly',
      icon: Icons.auto_awesome_mosaic_rounded,
      color: Colors.black,
      points: 200,
      time: '3 min',
      gradient: [Colors.black, Colors.grey.shade800],
    ),
    GameItem(
      id: 'tap',
      title: 'Tap Challenge',
      description: 'Tap as fast as you can',
      icon: Icons.touch_app_rounded,
      color: Colors.white,
      points: 120,
      time: '1 min',
      gradient: [Colors.white, Colors.grey.shade200],
    ),
  ];

  void _navigateToGame(BuildContext context, String gameId) {
    switch (gameId) {
      case 'spin':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SpinGameScreen()),
        );
        break;
      case 'color-match': // Updated from 'quiz'
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ColorMatchGameScreen()),
        );
        break;
      case 'match':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MatchGameScreen()),
        );
        break;
      case 'tap':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TapGameScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Earn & Play',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.account_balance_wallet_rounded,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
            onPressed: () {
              // Show points balance
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Play Games, Earn Rewards',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete games to earn points and unlock rewards',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Stats Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  isDark,
                  icon: Icons.star_rounded,
                  value: '2,450',
                  label: 'Total Points',
                ),
                _buildStatItem(
                  context,
                  isDark,
                  icon: Icons.games_rounded,
                  value: '12',
                  label: 'Games Played',
                ),
                _buildStatItem(
                  context,
                  isDark,
                  icon: Icons.emoji_events_rounded,
                  value: '5',
                  label: 'Rewards Won',
                ),
              ],
            ),
          ),

          // Games Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _games.length,
                itemBuilder: (context, index) {
                  final game = _games[index];
                  return GameCard(
                    game: game,
                    isDark: isDark,
                    onTap: () => _navigateToGame(context, game.id),
                  );
                },
              ),
            ),
          ),

          // Bottom Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Earn points by completing games. Points can be redeemed for rewards.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
          ),
          child: Icon(
            icon,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class GameItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int points;
  final String time;
  final List<Color> gradient;

  GameItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.points,
    required this.time,
    required this.gradient,
  });
}
