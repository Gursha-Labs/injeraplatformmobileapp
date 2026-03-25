// screens/spin_game_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:injera/models/spin_game/spin_response.dart';
import 'package:injera/services/spin_game_service.dart';

// Provider for spin game service
final spinGameServiceProvider = Provider((ref) => SpinGameService());

// Provider for user points
final userPointsProvider = StateProvider<int>((ref) => 0);

class SpinGameScreen extends ConsumerStatefulWidget {
  const SpinGameScreen({super.key});

  @override
  ConsumerState<SpinGameScreen> createState() => _SpinGameScreenState();
}

class _SpinGameScreenState extends ConsumerState<SpinGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _targetAngle = 0;

  double _currentAngle = 0;
  bool _isSpinning = false;
  bool _isLoading = true;

  int _userPoints = 0;
  double _betAmount = 0;

  List<String> _rewards = [];
  List<Color> _rewardColors = [];

  final SpinGameService _spinService = SpinGameService();

  static const double wheelSize = 320;

  @override
  void initState() {
    super.initState();
    _initializeGame();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _initializeGame() async {
    setState(() => _isLoading = true);

    try {
      // Fetch game variables and rewards
      final gameVariables = await _spinService.getGameVariables();
      final rewardsList = await _spinService.getRewards();

      // Filter only active rewards
      final activeRewards = rewardsList.where((r) => r.isActive).toList();

      // Prepare wheel segments from rewards
      if (activeRewards.isNotEmpty) {
        _rewards = activeRewards.map((r) => r.name).toList();
        _rewardColors = activeRewards
            .map((r) => _getRewardColor(r.type))
            .toList();
      } else {
        // Fallback if no active rewards
        _rewards = [
          "\$30",
          "\$10",
          "\$250",
          "\$20",
          "LOSE",
          "\$5",
          "\$500",
          "\$80",
        ];
        _rewardColors = [
          Colors.orange,
          Colors.red,
          Colors.blue,
          Colors.green,
          Colors.grey,
          Colors.purple,
          Colors.teal,
          Colors.amber,
        ];
      }

      _betAmount = gameVariables.betPoint;

      // Get user points
      _userPoints = await _spinService.getUserPoints();
      ref.read(userPointsProvider.notifier).state = _userPoints;
    } catch (e) {
      print('Error initializing game: $e');
      // Fallback to default values
      _rewards = [
        "\$30",
        "\$10",
        "\$250",
        "\$20",
        "LOSE",
        "\$5",
        "\$500",
        "\$80",
      ];
      _rewardColors = [
        Colors.orange,
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.grey,
        Colors.purple,
        Colors.teal,
        Colors.amber,
      ];
      _betAmount = 1.0;
      _userPoints = 0;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Using default values: ${e.toString()}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Color _getRewardColor(String type) {
    switch (type) {
      case 'money':
        return Colors.green;
      case 'point':
        return Colors.blue;
      case 'lose':
        return Colors.grey;
      case 'trial':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  Future<void> spinWheel() async {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });

    try {
      // Call backend spin API
      final spinResponse = await _spinService.spin();

      // Update user points immediately in UI
      setState(() {
        _userPoints = spinResponse.userPoints;
        ref.read(userPointsProvider.notifier).state = _userPoints;
      });

      // Animate wheel to the correct segment
      await _animateToSegment(spinResponse.segmentIndex);

      // Show result dialog after animation completes
      await _showResultDialog(spinResponse);
    } catch (e) {
      print('Error during spin: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      setState(() {
        _isSpinning = false;
      });
    }
  }

  Future<void> _animateToSegment(int targetIndex) async {
    if (_rewards.isEmpty) return;

    if (targetIndex < 0 || targetIndex >= _rewards.length) {
      targetIndex = 0;
    }

    double segmentAngle = 2 * pi / _rewards.length;

    // Calculate target angle
    double normalizedCurrent = _currentAngle % (2 * pi);
    double targetSegmentCenter = targetIndex * segmentAngle + segmentAngle / 2;
    double currentTargetCenter =
        (targetSegmentCenter + normalizedCurrent) % (2 * pi);

    const double pointerAngle = 3 * pi / 2;
    double rotationNeeded = (pointerAngle - currentTargetCenter) % (2 * pi);

    // Add extra rotations for visual effect (multiple full spins)
    int extraRotations = 6;
    double targetAngle =
        _currentAngle + rotationNeeded + (extraRotations * 2 * pi);

    // Remove previous listeners
    _animation.removeListener(_updateAngle);
    _animation.removeStatusListener(_onAnimationComplete);

    // Add new listeners
    _animation.addListener(_updateAngle);
    _animation.addStatusListener(_onAnimationComplete);

    _targetAngle = targetAngle;
    _controller.reset();
    await _controller.forward();
  }

  void _updateAngle() {
    setState(() {
      _currentAngle = _animation.value * _targetAngle;
    });
  }

  void _onAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _animation.removeListener(_updateAngle);
      _animation.removeStatusListener(_onAnimationComplete);
    }
  }

  Future<void> _showResultDialog(SpinResponse response) async {
    // Wait a moment for the wheel to settle
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              response.isWinner
                  ? Icons.emoji_events
                  : Icons.sentiment_dissatisfied,
              color: response.isWinner ? Colors.amber : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 10),
            Text(
              response.isWinner ? '🎉 You Won!' : '😢 Better Luck Next Time',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              response.rewardName,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: response.isWinner ? Colors.green : Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            if (response.isWinner && response.winAmount > 0)
              Text(
                'You won ${_formatRewardValue(response.rewardType, response.winAmount)}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 10),
            Text(
              response.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, color: Colors.amber, size: 20),
                  const SizedBox(width: 5),
                  Text(
                    'Your Points: ${response.userPoints}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isSpinning = false;
              });
            },
            child: const Text('Continue', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    ).then((_) {
      // Reset spinning state after dialog is closed
      if (mounted) {
        setState(() {
          _isSpinning = false;
        });
      }
    });
  }

  String _formatRewardValue(String type, double value) {
    switch (type) {
      case 'money':
        return '\$${value.toStringAsFixed(2)}';
      case 'point':
        return '${value.toInt()} Points';
      case 'trial':
        return '${value.toInt()} Days Free Trial';
      default:
        return value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spin & Win'),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_userPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wheel Container
            Container(
              width: wheelSize,
              height: wheelSize,
              margin: const EdgeInsets.all(20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  /// WHEEL
                  Transform.rotate(
                    angle: _currentAngle,
                    child: Container(
                      width: wheelSize,
                      height: wheelSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.3),
                            blurRadius: 25,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        painter: WheelPainter(_rewards, _rewardColors),
                      ),
                    ),
                  ),

                  /// CENTER BUTTON
                  GestureDetector(
                    onTap: _isSpinning ? null : spinWheel,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSpinning ? Colors.grey : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isSpinning ? Icons.hourglass_empty : Icons.play_arrow,
                        color: _isSpinning
                            ? Colors.grey.shade600
                            : Colors.amber,
                        size: 40,
                      ),
                    ),
                  ),

                  /// POINTER
                  Positioned(
                    top: -8,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// SPIN BUTTON
            ElevatedButton(
              onPressed: _isSpinning ? null : spinWheel,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: _isSpinning ? Colors.grey : Colors.white,
                foregroundColor: Colors.white,
                elevation: 5,
              ),
              child: Text(
                _isSpinning
                    ? "SPINNING..."
                    : "SPIN NOW (${_betAmount.toInt()} pts)",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Show bet amount info
            Text(
              'Cost: ${_betAmount.toInt()} points per spin',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

// Wheel Painter class
class WheelPainter extends CustomPainter {
  final List<String> rewards;
  final List<Color> colors;

  WheelPainter(this.rewards, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    if (rewards.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = 2 * pi / rewards.length;

    for (int i = 0; i < rewards.length; i++) {
      final startAngle = i * sweepAngle;

      final paint = Paint()..color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw segment dividers
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(.5)
        ..strokeWidth = 2;

      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(startAngle) * radius,
          center.dy + sin(startAngle) * radius,
        ),
        linePaint,
      );

      // Draw text
      final textPainter = TextPainter(
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.text = TextSpan(
        text: rewards[i],
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );

      textPainter.layout();

      final angle = startAngle + sweepAngle / 2;
      final x = center.dx + cos(angle) * radius * 0.7;
      final y = center.dy + sin(angle) * radius * 0.7;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle + pi / 2);

      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );

      canvas.restore();
    }

    // Draw outer circle
    final outerPaint = Paint()
      ..color = Colors.black.withOpacity(.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, outerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
