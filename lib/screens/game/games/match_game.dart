import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class MatchGameScreen extends ConsumerStatefulWidget {
  const MatchGameScreen({super.key});

  @override
  ConsumerState<MatchGameScreen> createState() => _MatchGameScreenState();
}

class _MatchGameScreenState extends ConsumerState<MatchGameScreen> {
  List<CardItem> _cards = [];
  List<int> _flippedIndices = [];
  int _matchedPairs = 0;
  int _moves = 0;
  int _score = 0;
  bool _gameWon = false;
  bool _canFlip = true;

  final List<String> _icons = [
    '❤️',
    '⭐',
    '🎯',
    '🎨',
    '⚽',
    '🎮',
    '🎵',
    '🎭',
    '🚀',
    '🏆',
    '💎',
    '🎪',
    '🎲',
    '🎳',
    '🎸',
    '🎭',
  ];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    final random = Random();
    List<String> selectedIcons = _icons.sublist(0, 8);
    selectedIcons = [...selectedIcons, ...selectedIcons];
    selectedIcons.shuffle(random);

    setState(() {
      _cards = List.generate(
        16,
        (index) => CardItem(
          icon: selectedIcons[index],
          isFlipped: false,
          isMatched: false,
        ),
      );
      _flippedIndices = [];
      _matchedPairs = 0;
      _moves = 0;
      _score = 1000;
      _gameWon = false;
      _canFlip = true;
    });
  }

  void _flipCard(int index) {
    if (!_canFlip ||
        _cards[index].isFlipped ||
        _cards[index].isMatched ||
        _flippedIndices.length == 2) {
      return;
    }

    setState(() {
      _cards[index] = _cards[index].copyWith(isFlipped: true);
      _flippedIndices.add(index);
      _moves++;
    });

    if (_flippedIndices.length == 2) {
      _canFlip = false;
      Future.delayed(const Duration(milliseconds: 500), () {
        _checkMatch();
      });
    }
  }

  void _checkMatch() {
    final index1 = _flippedIndices[0];
    final index2 = _flippedIndices[1];

    if (_cards[index1].icon == _cards[index2].icon) {
      setState(() {
        _cards[index1] = _cards[index1].copyWith(isMatched: true);
        _cards[index2] = _cards[index2].copyWith(isMatched: true);
        _matchedPairs++;
        _score += 200;
      });

      if (_matchedPairs == 8) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _gameWon = true;
          _showWinDialog();
        });
      }
    } else {
      Future.delayed(const Duration(milliseconds: 1000), () {
        setState(() {
          _cards[index1] = _cards[index1].copyWith(isFlipped: false);
          _cards[index2] = _cards[index2].copyWith(isFlipped: false);
          _score = _score > 50 ? _score - 50 : 0;
        });
      });
    }

    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _flippedIndices.clear();
        _canFlip = true;
      });
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration_rounded,
              size: 60,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            const Text(
              'Congratulations!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You matched all pairs!',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Moves:',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      Text(
                        '$_moves',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Score:',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      Text(
                        '$_score',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Time Bonus:',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      Text(
                        '+500',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _initializeGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Play Again'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Finish'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.pureBlack : AppColors.pureWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Match Pairs',
          style: TextStyle(
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            ),
            onPressed: _initializeGame,
          ),
        ],
      ),
      body: Column(
        children: [
          // Game Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Score',
                  '$_score',
                  Icons.star_rounded,
                  Colors.amber,
                  isDark,
                ),
                _buildStatItem(
                  'Pairs',
                  '$_matchedPairs/8',
                  Icons.check_rounded,
                  Colors.green,
                  isDark,
                ),
                _buildStatItem(
                  'Moves',
                  '$_moves',
                  Icons.directions_run_rounded,
                  Colors.blue,
                  isDark,
                ),
              ],
            ),
          ),

          // Game Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _cards.length,
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return GestureDetector(
                    onTap: () => _flipCard(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: card.isFlipped || card.isMatched
                            ? (isDark ? Colors.grey.shade800 : Colors.white)
                            : (isDark
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: card.isMatched
                              ? Colors.green
                              : (isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300),
                          width: card.isMatched ? 3 : 1,
                        ),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return RotationTransition(
                              turns: animation,
                              child: ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                            );
                          },
                          child: card.isFlipped || card.isMatched
                              ? Text(
                                  card.icon,
                                  style: const TextStyle(fontSize: 32),
                                )
                              : Icon(
                                  Icons.question_mark_rounded,
                                  size: 32,
                                  color: isDark
                                      ? Colors.grey.shade600
                                      : Colors.grey.shade400,
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Game Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _initializeGame,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Restart Game'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.grey.shade900
                              : Colors.grey.shade200,
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _gameWon
                            ? null
                            : () {
                                // Hint feature
                              },
                        icon: const Icon(Icons.lightbulb_outline_rounded),
                        label: const Text('Hint'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Find matching pairs of icons',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
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
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class CardItem {
  final String icon;
  final bool isFlipped;
  final bool isMatched;

  CardItem({
    required this.icon,
    required this.isFlipped,
    required this.isMatched,
  });

  CardItem copyWith({String? icon, bool? isFlipped, bool? isMatched}) {
    return CardItem(
      icon: icon ?? this.icon,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
