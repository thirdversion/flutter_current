import 'package:mission_control_example/components/space_backdrop_painter.dart';
import 'package:mission_control_example/space_mission_theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

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
                painter: SpaceBackdropPainter(showStarfield: showStarfield),
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

class MissionFooterAttribution extends StatelessWidget {
  const MissionFooterAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SpaceMissionTheme.border.withValues(alpha: 0.8),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          Image.asset(
            'assets/images/ThirdVersionLogo.png',
            height: 34,
            fit: BoxFit.contain,
          ),
          Link(
            uri: Uri.parse('https://thirdversion.ca'),
            target: LinkTarget.blank,
            builder: (context, followLink) => InkWell(
              onTap: followLink,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Built with ❤️ by Third Version Technology Ltd.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: SpaceMissionTheme.textMuted,
                        fontWeight: FontWeight.w600,
                        decorationColor: SpaceMissionTheme.textMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.open_in_new_rounded,
                      size: 16,
                      color: SpaceMissionTheme.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    this.icon,
    this.color = SpaceMissionTheme.accent,
    this.compact = false,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 10, vertical: 6)
          : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 14 : 16, color: color),
            SizedBox(width: compact ? 4 : 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
