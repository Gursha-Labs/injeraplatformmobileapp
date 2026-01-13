import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injera/providers/theme_provider.dart';
import 'package:injera/theme/app_colors.dart';

class SpinGameScreen extends ConsumerStatefulWidget {
  const SpinGameScreen({super.key});

  @override
  ConsumerState<SpinGameScreen> createState() => _SpinGameScreenState();
}

class _SpinGameScreenState extends ConsumerState<SpinGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _angle = 0.0;
  bool _isSpinning = false;
  List<String> _rewards = [
    '100 Points',
    '50 Points',
    '200 Points',
    'Try Again',
    '500 Points',
    '100 Points',
    '250 Points',
    'Bonus Spin',
  ];
  String? _result;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.decelerate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spinWheel() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
      _result = null;
    });

    final fullRotations = 5 + _random.nextInt(3);
    final targetAngle =
        fullRotations * 2 * pi + (_random.nextDouble() * 2 * pi);
    final randomIndex = _random.nextInt(_rewards.length);
    final selectedReward = _rewards[randomIndex];

    _controller.reset();
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _angle = targetAngle % (2 * pi);
          _isSpinning = false;
          _result = selectedReward;
        });

        _showResultDialog(selectedReward);
      }
    });

    setState(() {
      _angle = targetAngle;
    });
  }

  void _showResultDialog(String reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              reward.contains('Points')
                  ? Icons.celebration_rounded
                  : Icons.autorenew_rounded,
              size: 60,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              reward == 'Try Again'
                  ? 'Better luck next time!'
                  : 'Congratulations!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              reward,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider).isDarkMode;
    final screenHeight = MediaQuery.of(context).size.height;

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
          'Spin Wheel',
          style: TextStyle(
            color: isDark ? AppColors.pureWhite : AppColors.pureBlack,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: screenHeight * 0.05),

              // Wheel Container
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Wheel
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _isSpinning
                              ? _animation.value * _angle
                              : _angle,
                          child: CustomPaint(
                            size: const Size(280, 280),
                            painter: WheelPainter(
                              sections: _rewards.length,
                              isDark: isDark,
                            ),
                          ),
                        );
                      },
                    ),

                    // Center Circle
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 28,
                          ),
                        ),
                      ),
                    ),

                    // Pointer
                    Positioned(
                      top: 0,
                      left: 130,
                      child: Container(
                        width: 18,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(9),
                            bottomRight: Radius.circular(9),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Spin Button
              GestureDetector(
                onTap: _spinWheel,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isSpinning ? Colors.grey : Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isSpinning ? 'SPINNING...' : 'SPIN',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Rewards List
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _rewards.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade900
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _rewards[index].contains('Points')
                                ? Icons.star_rounded
                                : Icons.autorenew_rounded,
                            size: 14,
                            color: _rewards[index].contains('Points')
                                ? Colors.amber
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _rewards[index],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Result
              if (_result != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Last Result',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result!,
                        style: TextStyle(
                          color: _result!.contains('Points')
                              ? Colors.amber
                              : Colors.grey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Instructions
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: Text(
                  'Spin the wheel to win points and rewards!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final int sections;
  final bool isDark;

  WheelPainter({required this.sections, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final sweepAngle = 2 * pi / sections;

    // Draw sections
    for (int i = 0; i < sections; i++) {
      final startAngle = i * sweepAngle;
      final paint = Paint()
        ..color = i % 2 == 0
            ? (isDark ? Colors.white : Colors.black)
            : (isDark ? Colors.grey.shade900 : Colors.grey.shade300)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.grey.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        borderPaint,
      );
    }

    // Draw text labels
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < sections; i++) {
      final startAngle = i * sweepAngle;
      final label = '${i + 1}';
      final textStyle = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: i % 2 == 0
            ? (isDark ? Colors.black : Colors.white)
            : (isDark ? Colors.white : Colors.black),
      );

      textPainter.text = TextSpan(text: label, style: textStyle);
      textPainter.layout();

      final labelAngle = startAngle + sweepAngle / 2;
      final labelRadius = radius * 0.7;
      final labelX = center.dx + labelRadius * cos(labelAngle);
      final labelY = center.dy + labelRadius * sin(labelAngle);

      canvas.save();
      canvas.translate(labelX, labelY);
      canvas.rotate(labelAngle + pi / 2);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
