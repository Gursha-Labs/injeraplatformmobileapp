import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class ColorMatchGameScreen extends ConsumerStatefulWidget {
  const ColorMatchGameScreen({super.key});

  @override
  ConsumerState<ColorMatchGameScreen> createState() =>
      _ColorMatchGameScreenState();
}

class _ColorMatchGameScreenState extends ConsumerState<ColorMatchGameScreen> {
  int _score = 0;
  int _level = 1;
  int _timeLeft = 60;
  int _lives = 3;
  bool _gameStarted = false;
  bool _gameOver = false;
  late List<ColorItem> _colors;
  Color? _targetColor;
  final Random _random = Random();
  final List<Color> _colorPalette = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
    Colors.lime,
  ];

  @override
  void initState() {
    super.initState();
    _startNewLevel();
  }

  void _startNewLevel() {
    final numberOfColors = 3 + _level;
    final colorIndices = List.generate(
      numberOfColors,
      (index) => _random.nextInt(_colorPalette.length),
    ).toSet().toList();

    if (colorIndices.length < 3) {
      colorIndices.addAll([0, 1, 2].take(3 - colorIndices.length));
    }

    setState(() {
      _colors = colorIndices
          .sublist(0, min(numberOfColors, colorIndices.length))
          .map(
            (index) => ColorItem(color: _colorPalette[index], isTarget: false),
          )
          .toList();

      final targetIndex = _random.nextInt(_colors.length);
      _colors[targetIndex] = ColorItem(
        color: _colors[targetIndex].color,
        isTarget: true,
      );
      _targetColor = _colors[targetIndex].color;
      _gameStarted = true;
      _timeLeft = 60 - (_level * 5);
      if (_timeLeft < 20) _timeLeft = 20;
    });
  }

  void _selectColor(ColorItem colorItem) {
    if (!_gameStarted || _gameOver) return;

    if (colorItem.isTarget) {
      setState(() {
        _score += 100 * _level;
        _level++;
        _startNewLevel();
      });
    } else {
      setState(() {
        _lives--;
        if (_lives <= 0) {
          _gameOver = true;
          _showGameOver();
        }
      });
    }
  }

  void _showGameOver() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.color_lens_rounded, size: 60, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Game Over!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Level $_level',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
            ),
            const SizedBox(height: 5),
            Text(
              '$_score',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Total Score',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _restartGame();
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

  void _restartGame() {
    setState(() {
      _score = 0;
      _level = 1;
      _lives = 3;
      _gameOver = false;
      _startNewLevel();
    });
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
          'Color Match',
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
            onPressed: _restartGame,
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
                _buildGameStat(
                  'SCORE',
                  '$_score',
                  Icons.star_rounded,
                  Colors.amber,
                  isDark,
                ),
                _buildGameStat(
                  'LEVEL',
                  '$_level',
                  Icons.auto_awesome_rounded,
                  Colors.purple,
                  isDark,
                ),
                _buildGameStat(
                  'LIVES',
                  '$_lives',
                  Icons.favorite_rounded,
                  Colors.red,
                  isDark,
                ),
              ],
            ),
          ),

          // Target Color
          if (_gameStarted && !_gameOver && _targetColor != null) ...[
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Find this color:',
                    style: TextStyle(
                      fontSize: 20,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _targetColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: _targetColor!.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Text(
                        _getColorName(_targetColor!),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Timer
          if (_gameStarted && !_gameOver) ...[
            LinearProgressIndicator(
              value: _timeLeft / 60,
              backgroundColor: isDark
                  ? Colors.grey.shade800
                  : Colors.grey.shade200,
              color: _timeLeft > 40
                  ? Colors.green
                  : _timeLeft > 20
                  ? Colors.orange
                  : Colors.red,
              minHeight: 6,
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Time: $_timeLeft',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _timeLeft > 40
                      ? Colors.green
                      : _timeLeft > 20
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ),
          ],

          // Color Grid
          if (_gameStarted && !_gameOver)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: _colors.length,
                  itemBuilder: (context, index) {
                    final colorItem = _colors[index];
                    return GestureDetector(
                      onTap: () => _selectColor(colorItem),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: colorItem.color,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: colorItem.color.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white,
                            width: colorItem.isTarget ? 6 : 3,
                          ),
                        ),
                        child: Center(
                          child: colorItem.isTarget
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  size: 40,
                                  color: Colors.white,
                                )
                              : Text(
                                  _getColorName(colorItem.color),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // Game Instructions
          if (!_gameStarted || _gameOver)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.color_lens_rounded,
                      size: 100,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Color Match',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Find the matching color among the options.\nTap the correct one to advance levels!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: _restartGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'START GAME',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Game Controls
          if (_gameStarted && !_gameOver)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Level $_level: Find the matching color',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Hint feature
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Look for the color that matches the target',
                                ),
                                backgroundColor: Colors.black,
                              ),
                            );
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _restartGame,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Restart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDark
                                ? Colors.grey.shade900
                                : Colors.grey.shade200,
                            foregroundColor: isDark
                                ? Colors.white
                                : Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameStat(
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
            fontSize: 24,
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

  String _getColorName(Color color) {
    if (color == Colors.red) return 'RED';
    if (color == Colors.blue) return 'BLUE';
    if (color == Colors.green) return 'GREEN';
    if (color == Colors.yellow) return 'YELLOW';
    if (color == Colors.purple) return 'PURPLE';
    if (color == Colors.orange) return 'ORANGE';
    if (color == Colors.pink) return 'PINK';
    if (color == Colors.teal) return 'TEAL';
    if (color == Colors.indigo) return 'INDIGO';
    if (color == Colors.amber) return 'AMBER';
    if (color == Colors.cyan) return 'CYAN';
    if (color == Colors.lime) return 'LIME';
    return 'COLOR';
  }
}

class ColorItem {
  final Color color;
  final bool isTarget;

  ColorItem({required this.color, required this.isTarget});
}
