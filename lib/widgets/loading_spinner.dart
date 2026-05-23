// loading_spinner.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'dart:math';

class InjeraLoadingSpinner extends StatefulWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? accentColor;
  final double strokeWidth;
  final Duration duration;
  final String? loadingText;
  final TextStyle? textStyle;

  const InjeraLoadingSpinner({
    Key? key,
    this.size = 60.0,
    this.primaryColor,
    this.secondaryColor,
    this.accentColor,
    this.strokeWidth = 4.0,
    this.duration = const Duration(milliseconds: 1500),
    this.loadingText,
    this.textStyle,
  }) : super(key: key);

  @override
  State<InjeraLoadingSpinner> createState() => _InjeraLoadingSpinnerState();
}

class _InjeraLoadingSpinnerState extends State<InjeraLoadingSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  // Ethiopian flag colors with injera inspiration
  static const Color _defaultBlack = Color(0xFF1A1A1A);
  static const Color _defaultWhite = Color(0xFFF5F5F5);
  static const Color _defaultRed = Color(0xFFDA251D);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..repeat();

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.primaryColor ?? _defaultRed;
    final secondary = widget.secondaryColor ?? _defaultWhite;
    final accent = widget.accentColor ?? _defaultBlack;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    painter: _InjeraSpinnerPainter(
                      progress: _controller.value,
                      rotation: _rotationAnimation.value,
                      primaryColor: primary,
                      secondaryColor: secondary,
                      accentColor: accent,
                      strokeWidth: widget.strokeWidth,
                    ),
                    size: Size(widget.size, widget.size),
                  ),
                ),
              );
            },
          ),
          if (widget.loadingText != null) ...[
            const SizedBox(height: 16),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Text(
                      widget.loadingText!,
                      style:
                          widget.textStyle ??
                          TextStyle(
                            color: primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2,
                          ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _InjeraSpinnerPainter extends CustomPainter {
  final double progress;
  final double rotation;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final double strokeWidth;

  _InjeraSpinnerPainter({
    required this.progress,
    required this.rotation,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.save();

    // Main rotating Injera circle (like a flatbread being cooked)
    final mainRotation = rotation;
    canvas.rotate(mainRotation);

    // Draw the main Injera body (circle with ripple effect)
    for (int i = 0; i < 3; i++) {
      final pulseDelay = (progress * 2 * pi) + (i * 2 * pi / 3);
      final pulseScale = 0.8 + (sin(pulseDelay) * 0.2);
      final currentRadius = radius * pulseScale;
      final currentRect = Rect.fromCircle(
        center: center,
        radius: currentRadius,
      );

      final Paint pulsePaint = Paint()
        ..color = i == 0
            ? primaryColor
            : (i == 1 ? secondaryColor : accentColor)
        ..strokeWidth = strokeWidth * (0.5 + sin(pulseDelay) * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(currentRect, 0, 2 * pi, false, pulsePaint);
    }

    canvas.restore();

    // Draw the porous Injera texture (bubbles that appear and disappear)
    final bubbleCount = 24;
    final bubbleProgress = (progress * 2 * pi);

    for (int i = 0; i < bubbleCount; i++) {
      final angle = (i * 2 * pi / bubbleCount);
      final bubbleDistance =
          radius * (0.4 + sin(angle * 3 + bubbleProgress) * 0.2);
      final x = center.dx + bubbleDistance * cos(angle + bubbleProgress);
      final y = center.dy + bubbleDistance * sin(angle + bubbleProgress);

      // Bubbles appear and disappear
      final bubbleVisibility = (sin(angle * 5 - bubbleProgress * 2) + 1) / 2;
      final bubbleRadius = (strokeWidth * 0.8) * (0.3 + bubbleVisibility * 0.7);

      if (bubbleVisibility > 0.3) {
        final bubblePaint = Paint()
          ..color =
              (i % 3 == 0
                      ? primaryColor
                      : (i % 3 == 1 ? secondaryColor : accentColor))
                  .withOpacity(bubbleVisibility * 0.8)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), bubbleRadius, bubblePaint);
      }
    }

    // Draw rotating Ethiopian cross pattern
    final crossProgress = rotation * 2;
    for (int i = 0; i < 4; i++) {
      final crossAngle = (i * pi / 2) + crossProgress;
      final innerRadius = radius * 0.3;
      final outerRadius = radius * 0.7;

      final startPoint = Offset(
        center.dx + innerRadius * cos(crossAngle),
        center.dy + innerRadius * sin(crossAngle),
      );
      final endPoint = Offset(
        center.dx + outerRadius * cos(crossAngle),
        center.dy + outerRadius * sin(crossAngle),
      );

      final crossPaint = Paint()
        ..color = primaryColor
        ..strokeWidth = strokeWidth * 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(startPoint, endPoint, crossPaint);
    }

    // Draw expanding center (like the center of Injera)
    final centerPulse = 0.5 + sin(progress * 2 * pi) * 0.3;
    final centerRadius = radius * 0.15 * centerPulse;

    // Center core
    final centerPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, centerRadius, centerPaint);

    // Center glow
    final glowPaint = Paint()
      ..color = secondaryColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.8;
    canvas.drawCircle(center, centerRadius * 1.5, glowPaint);

    // Draw swirling injera folds (3 rotating arcs)
    for (int i = 0; i < 3; i++) {
      final startAngle = (rotation * 2) + (i * 2 * pi / 3);
      final sweepAngle = pi * (0.3 + sin(progress * 2 * pi) * 0.1);

      final foldPaint = Paint()
        ..shader = _createRadialGradient(center, radius, i)
        ..strokeWidth = strokeWidth * 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, foldPaint);
    }

    // Draw decorative dots around the edge (like sesame seeds on Injera)
    final seedCount = 16;
    for (int i = 0; i < seedCount; i++) {
      final seedAngle = (rotation * 0.5) + (i * 2 * pi / seedCount);
      final seedDistance = radius * 0.95;
      final seedX = center.dx + seedDistance * cos(seedAngle);
      final seedY = center.dy + seedDistance * sin(seedAngle);

      final seedPulse = 0.5 + sin(progress * 4 * pi + i) * 0.5;
      final seedSize = strokeWidth * 0.4 * (0.5 + seedPulse * 0.5);

      final seedPaint = Paint()
        ..color = (i % 2 == 0 ? secondaryColor : accentColor)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(seedX, seedY), seedSize, seedPaint);
    }
  }

  Shader? _createRadialGradient(Offset center, double radius, int index) {
    final colors = index == 0
        ? [primaryColor, primaryColor.withOpacity(0.2)]
        : index == 1
        ? [secondaryColor, secondaryColor.withOpacity(0.2)]
        : [accentColor, accentColor.withOpacity(0.2)];

    return RadialGradient(
      colors: colors,
      center: Alignment.center,
      radius: 0.8,
    ).createShader(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldRepaint(_InjeraSpinnerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.rotation != rotation;
  }
}

// Alternative: TikTok-style compact loading spinner
class TikTokInjeraSpinner extends StatelessWidget {
  final double size;
  final Color? color;

  const TikTokInjeraSpinner({Key? key, this.size = 40.0, this.color})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer spinning ring (Red)
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * pi,
                child: CircularProgressIndicator(
                  value: null,
                  strokeWidth: size * 0.1,
                  color: color ?? const Color(0xFFDA251D),
                ),
              );
            },
          ),
          // Inner spinning ring (White)
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: -value * 2 * pi,
                child: SizedBox(
                  width: size * 0.7,
                  height: size * 0.7,
                  child: CircularProgressIndicator(
                    value: null,
                    strokeWidth: size * 0.08,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          // Center dot (Black)
          Container(
            width: size * 0.15,
            height: size * 0.15,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// Usage example with different styles
class LoadingSpinnerDemo extends StatelessWidget {
  const LoadingSpinnerDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Full version with text
            const InjeraLoadingSpinner(
              size: 80,
              loadingText: 'እንጀራ እየተዘጋጀ ነው...',
              textStyle: TextStyle(
                color: Color(0xFFDA251D),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            // TikTok compact version
            const TikTokInjeraSpinner(size: 50),
            const SizedBox(height: 20),
            // Custom colors version
            InjeraLoadingSpinner(
              size: 60,
              primaryColor: const Color(0xFFDA251D),
              secondaryColor: Colors.white,
              accentColor: Colors.black,
              strokeWidth: 5,
              duration: const Duration(milliseconds: 2000),
            ),
          ],
        ),
      ),
    );
  }
}
