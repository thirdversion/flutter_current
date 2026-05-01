import 'package:current/current.dart';
import 'package:mission_control_example/space_mission_theme.dart';
import 'package:flutter/material.dart';

import '../components/mission_control_theme.dart';
import '../view_models/telemetry_lab_view_model.dart';

class TelemetryLabPage extends CurrentWidget<TelemetryLabViewModel> {
  const TelemetryLabPage({super.key, required super.viewModel});

  @override
  CurrentState<TelemetryLabPage, TelemetryLabViewModel> createCurrent() {
    return _TelemetryLabPageState(viewModel);
  }
}

class _TelemetryLabPageState
    extends CurrentState<TelemetryLabPage, TelemetryLabViewModel> {
  _TelemetryLabPageState(super.viewModel);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 500;
    final isTablet = width < 1000;
    final columns = isTablet ? 1 : 2;
    final textTheme = Theme.of(context).textTheme;
    final cardSpacing = isMobile ? 10.0 : 12.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile
          ? 12
          : isTablet
              ? 14
              : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionPanel(
            padding: EdgeInsets.all(isMobile ? 12 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Telemetry Lab',
                  style: isMobile
                      ? textTheme.titleLarge
                      : textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Every card is driven by typed CurrentProperty. Change values, observe dirty state, and reset or commit a baseline.',
                  style: (isMobile ? textTheme.bodySmall : textTheme.bodyMedium)
                      ?.copyWith(
                    color: SpaceMissionTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: isMobile ? 6 : 10,
                    runSpacing: 6,
                    children: [
                      StatusPill(
                        label: viewModel.isDirty ? 'Dirty' : 'Synced',
                        icon: viewModel.isDirty
                            ? Icons.edit_outlined
                            : Icons.check_circle_outline,
                        color: viewModel.isDirty
                            ? SpaceMissionTheme.warning
                            : SpaceMissionTheme.highlight,
                        compact: isMobile,
                      ),
                      StatusPill(
                        label: viewModel.autopilotArmed.isTrue
                            ? 'Autopilot'
                            : 'Manual',
                        icon: Icons.auto_mode_outlined,
                        color: viewModel.autopilotArmed.isTrue
                            ? SpaceMissionTheme.accent
                            : SpaceMissionTheme.textMuted,
                        compact: isMobile,
                      ),
                      StatusPill(
                        label: 'Burn ${_formatTime(viewModel.nextBurn.value)}',
                        icon: Icons.schedule_outlined,
                        compact: isMobile,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (isMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton.icon(
                        onPressed: viewModel.simulateOrbitalBoost,
                        icon: const Icon(Icons.rocket_launch_outlined),
                        label: const Text('Orbital boost'),
                      ),
                      const SizedBox(height: 6),
                      FilledButton.tonalIcon(
                        onPressed: viewModel.commitBaseline,
                        icon: const Icon(Icons.bookmark_added_outlined),
                        label: const Text('Commit'),
                      ),
                      const SizedBox(height: 6),
                      OutlinedButton.icon(
                        onPressed: viewModel.resetAll,
                        icon: const Icon(Icons.restart_alt_outlined),
                        label: const Text('Reset'),
                      ),
                    ],
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: viewModel.simulateOrbitalBoost,
                        icon: const Icon(Icons.rocket_launch_outlined),
                        label: const Text('Load orbital boost'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: viewModel.commitBaseline,
                        icon: const Icon(Icons.bookmark_added_outlined),
                        label: const Text('Commit baseline'),
                      ),
                      OutlinedButton.icon(
                        onPressed: viewModel.resetAll,
                        icon: const Icon(Icons.restart_alt_outlined),
                        label: const Text('Reset all'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 10 : 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = columns == 1
                  ? constraints.maxWidth
                  : (constraints.maxWidth - cardSpacing) / 2;

              return Wrap(
                spacing: cardSpacing,
                runSpacing: cardSpacing,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: _TelemetryCard(
                      title: 'Mission Callsign',
                      subtitle: 'CurrentStringProperty',
                      icon: Icons.badge_outlined,
                      accentColor: SpaceMissionTheme.accent,
                      value: viewModel.missionName.value,
                      originalValue: viewModel.missionName.originalValue,
                      dirty: viewModel.missionName.isDirty,
                      onPressed: viewModel.rotateCallsign,
                      actionLabel: 'Rotate',
                      compact: isMobile,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _TelemetryCard(
                      title: 'Crew Count',
                      subtitle: 'CurrentIntProperty',
                      icon: Icons.groups_2_outlined,
                      accentColor: SpaceMissionTheme.highlight,
                      value: '${viewModel.crewCount.value} crew',
                      originalValue: '${viewModel.crewCount.originalValue}',
                      dirty: viewModel.crewCount.isDirty,
                      onPressed: viewModel.cycleCrewCount,
                      actionLabel: 'Cycle',
                      compact: isMobile,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _TelemetryCard(
                      title: 'Thrust Output',
                      subtitle: 'CurrentDoubleProperty',
                      icon: Icons.speed_outlined,
                      accentColor: SpaceMissionTheme.warning,
                      value: '${viewModel.thrust.value.toStringAsFixed(1)}%',
                      originalValue:
                          '${viewModel.thrust.originalValue.toStringAsFixed(1)}%',
                      dirty: viewModel.thrust.isDirty,
                      onPressed: viewModel.boostThrust,
                      actionLabel: 'Boost',
                      compact: isMobile,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _TelemetryCard(
                      title: 'Autopilot',
                      subtitle: 'CurrentBoolProperty',
                      icon: Icons.toggle_on_outlined,
                      accentColor: SpaceMissionTheme.accentStrong,
                      value:
                          viewModel.autopilotArmed.isTrue ? 'Armed' : 'Manual',
                      originalValue: viewModel.autopilotArmed.originalValue
                          ? 'Armed'
                          : 'Manual',
                      dirty: viewModel.autopilotArmed.isDirty,
                      onPressed: viewModel.toggleAutopilot,
                      actionLabel:
                          viewModel.autopilotArmed.isTrue ? 'Manual' : 'Arm',
                      compact: isMobile,
                    ),
                  ),
                  SizedBox(
                    width: cardWidth,
                    child: _TelemetryCard(
                      title: 'Burn Window',
                      subtitle: 'CurrentDateTimeProperty',
                      icon: Icons.event_available_outlined,
                      accentColor: SpaceMissionTheme.highlight,
                      value: _formatDate(viewModel.nextBurn.value),
                      originalValue:
                          _formatDate(viewModel.nextBurn.originalValue),
                      dirty: viewModel.nextBurn.isDirty,
                      onPressed: viewModel.delayBurn,
                      actionLabel: 'Delay 90m',
                      compact: isMobile,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$month-$day $hour:$minute';
  }

  static String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class _TelemetryCard extends StatelessWidget {
  const _TelemetryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.value,
    required this.originalValue,
    required this.dirty,
    required this.onPressed,
    required this.actionLabel,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String value;
  final String originalValue;
  final bool dirty;
  final VoidCallback onPressed;
  final String actionLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final detailLabelStyle = textTheme.labelSmall?.copyWith(
      color: SpaceMissionTheme.textMuted,
      letterSpacing: 0.3,
    );
    final detailValueStyle =
        (compact ? textTheme.bodySmall : textTheme.bodyMedium)
            ?.copyWith(fontWeight: FontWeight.w600);

    return MissionPanel(
      padding: EdgeInsets.all(compact ? 10 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 8 : 10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(compact ? 12 : 16),
                ),
                child: Icon(
                  icon,
                  size: compact ? 18 : 20,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: compact
                          ? textTheme.titleSmall
                          : textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          (compact ? textTheme.bodySmall : textTheme.bodyMedium)
                              ?.copyWith(
                        color: SpaceMissionTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(compact ? 14 : 16),
              border: Border.all(
                color: SpaceMissionTheme.border.withValues(alpha: 0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live reading',
                  style: detailLabelStyle,
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style:
                      compact ? textTheme.titleLarge : textTheme.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                _TelemetryDetailRow(
                  icon: Icons.layers_outlined,
                  label: 'Baseline',
                  value: originalValue,
                  labelStyle: detailLabelStyle,
                  valueStyle: detailValueStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              StatusPill(
                label: dirty ? 'Dirty' : 'Match',
                icon: dirty
                    ? Icons.edit_note_outlined
                    : Icons.check_circle_outline,
                color: dirty
                    ? SpaceMissionTheme.warning
                    : SpaceMissionTheme.highlight,
                compact: compact,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: onPressed,
                  icon: Icon(
                    icon,
                    size: compact ? 16 : 18,
                  ),
                  label: Text(
                    actionLabel,
                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TelemetryDetailRow extends StatelessWidget {
  const _TelemetryDetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.labelStyle,
    this.valueStyle,
  });

  final String label;
  final String value;
  final IconData icon;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: SpaceMissionTheme.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: labelStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: valueStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
