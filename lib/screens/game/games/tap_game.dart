import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class TapGameScreen extends ConsumerStatefulWidget {
  const TapGameScreen({super.key});

  @override
  ConsumerState<TapGameScreen> createState() => _TapGameScreenState();
}

class _TapGameScreenState extends ConsumerState<TapGameScreen> {
  int _score = 0;
  int _timeLeft = 30;
  bool _gameStarted = false;
  bool _gameOver = false;
  Timer? _timer;
  List<TapTarget> _targets = [];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    setState(() {
      _score = 0;
      _timeLeft = 30;
      _gameStarted = false;
      _gameOver = false;
      _targets = [];
    });
  }

  void _startGame() {
    setState(() {
      _gameStarted = true;
      _targets = List.generate(
        6,
        (index) => TapTarget(
          id: index,
          x: 0.2 + (index % 3) * 0.3,
          y: 0.2 + (index ~/ 3) * 0.3,
          size: 60.0,
          isActive: true,
        ),
      );
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft--;
        if (_timeLeft <= 0) {
          timer.cancel();
          _gameOver = true;
          _showGameOver();
        }
      });
    });
  }

  void _tapTarget(int id) {
    if (!_gameStarted || _gameOver) return;

    setState(() {
      _score += 10;
      _targets = _targets.map((target) {
        if (target.id == id) {
          return TapTarget(
            id: target.id,
            x: _getRandomPosition().dx,
            y: _getRandomPosition().dy,
            size: target.size,
            isActive: true,
          );
        }
        return target;
      }).toList();
    });
  }

  Offset _getRandomPosition() {
    final random = DateTime.now().microsecondsSinceEpoch % 100 / 100;
    return Offset(
      0.1 + (random * 0.7),
      0.1 + ((random * 100).floor() % 7 * 0.1),
    );
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
            const Icon(Icons.timer_off_rounded, size: 60, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Time\'s Up!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Final Score',
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
              'Taps Per Second: ${(_score / 30).toStringAsFixed(1)}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _initializeGame();
                      _startGame();
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
    final screenWidth = MediaQuery.of(context).size.width;

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
          'Tap Challenge',
          style: TextStyle(
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Game Stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGameStat(
                  'SCORE',
                  '$_score',
                  Icons.star_rounded,
                  Colors.amber,
                  isDark,
                ),
                _buildGameStat(
                  'TIME',
                  '$_timeLeft',
                  Icons.timer_rounded,
                  _timeLeft > 10 ? Colors.green : Colors.red,
                  isDark,
                ),
                _buildGameStat(
                  'TARGETS',
                  '${_targets.length}',
                  Icons.touch_app_rounded,
                  Colors.blue,
                  isDark,
                ),
              ],
            ),
          ),

          // Game Area
          Expanded(
            child: Stack(
              children: [
                // Background Pattern
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isDark
                            ? [Colors.grey.shade900, Colors.black]
                            : [Colors.grey.shade100, Colors.white],
                      ),
                    ),
                  ),
                ),

                // Game Instruction
                if (!_gameStarted)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_rounded,
                          size: 100,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        const SizedBox(height: 30),
                        Text(
                          'Tap Challenge',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tap as many targets as you can\nin 30 seconds!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: _startGame,
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

                // Game Targets
                if (_gameStarted && !_gameOver)
                  ..._targets.map((target) {
                    return Positioned(
                      left: target.x * screenWidth - target.size / 2,
                      top: target.y * 400,
                      child: GestureDetector(
                        onTap: () => _tapTarget(target.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: target.size,
                          height: target.size,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add_rounded,
                              size: target.size * 0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                // Game Timer
                if (_gameStarted && !_gameOver)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '$_timeLeft',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                // Score Display
                if (_gameStarted && !_gameOver)
                  Positioned(
                    bottom: 40,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          'Score: $_score',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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
                    'Tap the red circles as fast as you can!',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _timeLeft / 30,
                    backgroundColor: isDark
                        ? Colors.grey.shade800
                        : Colors.grey.shade200,
                    color: _timeLeft > 15
                        ? Colors.green
                        : _timeLeft > 5
                        ? Colors.orange
                        : Colors.red,
                    minHeight: 8,
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
            fontSize: 28,
            fontWeight: FontWeight.w900,
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

class TapTarget {
  final int id;
  final double x;
  final double y;
  final double size;
  final bool isActive;

  TapTarget({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.isActive,
  });
}
