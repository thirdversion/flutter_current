import 'dart:math' as math;

import 'package:flutter/material.dart';

class SpaceMissionTheme {
  static const Color deepSpace = Color(0xFF050816);
  static const Color deepSpaceSecondary = Color(0xFF0B1230);
  static const Color panel = Color(0xCC111A3D);
  static const Color panelStrong = Color(0xF0141F49);
  static const Color accent = Color(0xFF6FD3FF);
  static const Color accentStrong = Color(0xFF42A5F5);
  static const Color highlight = Color(0xFF86F9C8);
  static const Color warning = Color(0xFFFFB85C);
  static const Color danger = Color(0xFFFF6E7A);
  static const Color textMuted = Color(0xFF9CB1D6);
  static const Color border = Color(0xFF23325E);

  static ThemeData get themeData {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentStrong,
      brightness: Brightness.dark,
    ).copyWith(
      primary: accent,
      secondary: highlight,
      surface: panelStrong,
      onSurface: Colors.white,
      error: danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontSize: 38,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.8,
          height: 1.1,
        ),
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardThemeData(
        color: panelStrong,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: panelStrong,
        selectedColor: accentStrong.withValues(alpha: 0.2),
        secondarySelectedColor: accentStrong.withValues(alpha: 0.2),
        side: const BorderSide(color: border),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.03),
        labelStyle: const TextStyle(color: textMuted),
        helperStyle: const TextStyle(color: textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: accent, width: 1.4),
        ),
      ),
    );
  }

  static LinearGradient get backgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          deepSpace,
          deepSpaceSecondary,
          Color(0xFF081A2A),
        ],
      );

  static BoxDecoration panelDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? panel,
      borderRadius: BorderRadius.circular(28),
      border: Border.all(color: border.withValues(alpha: 0.9)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66030A1E),
          blurRadius: 42,
          offset: Offset(0, 24),
        ),
      ],
    );
  }
}

class SpaceBackdrop extends StatelessWidget {
  const SpaceBackdrop({
    super.key,
    required this.child,
    required this.showStarfield,
  });

  final Widget child;
  final bool showStarfield;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: SpaceMissionTheme.backgroundGradient),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _SpaceBackdropPainter(showStarfield: showStarfield),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class MissionPanel extends StatelessWidget {
  const MissionPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SpaceMissionTheme.panelDecoration(color: color),
      padding: padding,
      child: child,
    );
  }
}

class CurrentBrandMark extends StatelessWidget {
  const CurrentBrandMark({
    super.key,
    this.expanded = false,
    this.height = 44,
  });

  final bool expanded;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      expanded
          ? 'assets/images/CurrentLogoFull.png'
          : 'assets/images/CurrentLogoMD.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.icon,
    this.color = SpaceMissionTheme.accent,
  });

  final String label;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceBackdropPainter extends CustomPainter {
  const _SpaceBackdropPainter({required this.showStarfield});

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
  bool shouldRepaint(_SpaceBackdropPainter oldDelegate) {
    return oldDelegate.showStarfield != showStarfield;
  }
}
