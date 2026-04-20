import 'dart:math' as math;
import 'package:current_counter_example/space_mission_theme.dart';
import 'package:flutter/material.dart';

class SpaceBackdropPainter extends CustomPainter {
  const SpaceBackdropPainter({required this.showStarfield});

  final bool showStarfield;

  @override
  void paint(Canvas canvas, Size size) {
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.06);

    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.1),
      size.shortestSide * 0.22,
      orbitPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.78),
      size.shortestSide * 0.28,
      orbitPaint,
    );

    final auroraPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          SpaceMissionTheme.accent.withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.15, size.height * 0.2),
          radius: size.shortestSide * 0.35,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.2),
      size.shortestSide * 0.35,
      auroraPaint,
    );

    if (!showStarfield) {
      return;
    }

    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.75);
    final random = math.Random(42);

    for (var index = 0; index < 120; index++) {
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.8 + 0.4;
      starPaint.color = Colors.white.withValues(
        alpha: 0.15 + random.nextDouble() * 0.65,
      );
      canvas.drawCircle(Offset(dx, dy), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(SpaceBackdropPainter oldDelegate) {
    return oldDelegate.showStarfield != showStarfield;
  }
}
