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
  bool _hasInsufficientPoints = false;

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
      duration: const Duration(seconds: 5),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    );
  }

  Future<void> _initializeGame() async {
    setState(() => _isLoading = true);

    try {
      // Fetch game variables and rewards
      final gameVariables = await _spinService.getGameVariables();
      final rewardsList = await _spinService.getRewards();

      // Filter only active rewards and sort by probability
      final activeRewards = rewardsList.where((r) => r.isActive).toList();

      // Prepare wheel segments from rewards
      _rewards = activeRewards.map((r) => r.name).toList();
      _rewardColors = activeRewards
          .map((r) => _getRewardColor(r.type))
          .toList();

      _betAmount = gameVariables.betPoint;

      // Get user points
      _userPoints = await _spinService.getUserPoints();
      ref.read(userPointsProvider.notifier).state = _userPoints;

      // Check if user has enough points
      _hasInsufficientPoints = _userPoints < _betAmount;

      if (_hasInsufficientPoints) {
        _showInsufficientPointsDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing game: ${e.toString()}')),
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

  void _showInsufficientPointsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Insufficient Points'),
        content: Text(
          'You need $_betAmount points to play. You have $_userPoints points.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to earn points screen
              // Navigator.pushNamed(context, '/earn-points');
            },
            child: const Text('Earn Points'),
          ),
        ],
      ),
    );
  }

  Future<void> spinWheel() async {
    if (_isSpinning || _hasInsufficientPoints) return;

    setState(() => _isSpinning = true);

    try {
      // Call backend spin API
      final spinResponse = await _spinService.spin();

      // Update user points in UI
      setState(() {
        _userPoints = spinResponse.userPoints;
        ref.read(userPointsProvider.notifier).state = _userPoints;
      });

      // Animate wheel to the correct segment
      await _animateToSegment(spinResponse.segmentIndex);

      // Show result dialog
      _showResultDialog(spinResponse);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
      setState(() => _isSpinning = false);
    }
  }

  Future<void> _animateToSegment(int targetIndex) async {
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

    // Add extra rotations for visual effect
    int extraRotations = 8;
    double targetAngle =
        _currentAngle + rotationNeeded + (extraRotations * 2 * pi);

    // Remove previous listeners
    _animation.removeListener(_updateAngle);
    _animation.removeStatusListener(_onAnimationComplete);

    // Add new listeners
    _animation.addListener(_updateAngle);
    _animation.addStatusListener(_onAnimationComplete);

    _controller.reset();
    await _controller.forward();

    // Store target for verification
    _targetAngle = targetAngle;
  }

  void _updateAngle() {
    setState(() {
      _currentAngle = _animation.value * _targetAngle;
    });
  }

  void _onAnimationComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() => _isSpinning = false);
      _animation.removeListener(_updateAngle);
      _animation.removeStatusListener(_onAnimationComplete);
    }
  }

  void _showResultDialog(SpinResponse response) {
    showDialog(
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
            const SizedBox(height: 10),
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
              // Check if points are still sufficient for another spin
              if (_userPoints < _betAmount) {
                _showInsufficientPointsDialog();
              }
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
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
            if (_hasInsufficientPoints)
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Insufficient points! Need $_betAmount points to play.',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),

            Stack(
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
                  onTap: _hasInsufficientPoints ? null : spinWheel,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _hasInsufficientPoints
                          ? Colors.grey
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: _hasInsufficientPoints
                          ? Colors.grey.shade600
                          : Colors.amber,
                      size: 40,
                    ),
                  ),
                ),

                /// POINTER
                Positioned(
                  top: -8,
                  child: Container(
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
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// SPIN BUTTON
            ElevatedButton(
              onPressed: (_isSpinning || _hasInsufficientPoints)
                  ? null
                  : spinWheel,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                backgroundColor: (_isSpinning || _hasInsufficientPoints)
                    ? Colors.grey
                    : Colors.white,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _isSpinning
                    ? "SPINNING..."
                    : (_hasInsufficientPoints
                          ? "INSUFFICIENT POINTS"
                          : "SPIN NOW (${_betAmount.toInt()} pts)"),
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

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

// (Removed unused extension _AnimationTarget)

// Wheel Painter class
class WheelPainter extends CustomPainter {
  final List<String> rewards;
  final List<Color> colors;

  WheelPainter(this.rewards, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
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
