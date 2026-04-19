import 'package:current/current.dart';
import 'package:flutter/material.dart';

import '../mission_control_theme.dart';
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
    final columns = width > 1320
        ? 3
        : width > 900
            ? 2
            : 1;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Telemetry Lab', style: textTheme.headlineMedium),
                const SizedBox(height: 10),
                Text(
                  'Every card on this deck is driven by a typed CurrentProperty. Change the values, observe dirty state, and then reset or commit a new baseline with no manual widget bookkeeping.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: SpaceMissionTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    StatusPill(
                      label: viewModel.isDirty
                          ? 'Dirty telemetry'
                          : 'Telemetry synced',
                      icon: viewModel.isDirty
                          ? Icons.edit_outlined
                          : Icons.check_circle_outline,
                      color: viewModel.isDirty
                          ? SpaceMissionTheme.warning
                          : SpaceMissionTheme.highlight,
                    ),
                    StatusPill(
                      label: viewModel.autopilotArmed.isTrue
                          ? 'Autopilot armed'
                          : 'Autopilot manual',
                      icon: Icons.auto_mode_outlined,
                      color: viewModel.autopilotArmed.isTrue
                          ? SpaceMissionTheme.accent
                          : SpaceMissionTheme.textMuted,
                    ),
                    StatusPill(
                      label:
                          'Next burn ${_formatDate(viewModel.nextBurn.value)}',
                      icon: Icons.schedule_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: viewModel.simulateOrbitalBoost,
                      icon: const Icon(Icons.rocket_launch_outlined),
                      label: const Text('Load orbital boost profile'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: viewModel.commitBaseline,
                      icon: const Icon(Icons.bookmark_added_outlined),
                      label: const Text('Commit current values as baseline'),
                    ),
                    OutlinedButton.icon(
                      onPressed: viewModel.resetAll,
                      icon: const Icon(Icons.restart_alt_outlined),
                      label: const Text('Reset all telemetry'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            mainAxisSpacing: 18,
            crossAxisSpacing: 18,
            childAspectRatio: columns == 1 ? 1.45 : 1.08,
            children: [
              _TelemetryCard(
                title: 'Mission Callsign',
                subtitle: 'CurrentStringProperty',
                icon: Icons.badge_outlined,
                accentColor: SpaceMissionTheme.accent,
                value: viewModel.missionName.value,
                originalValue: viewModel.missionName.originalValue,
                dirty: viewModel.missionName.isDirty,
                onPressed: viewModel.rotateCallsign,
                actionLabel: 'Rotate callsign',
              ),
              _TelemetryCard(
                title: 'Crew Count',
                subtitle: 'CurrentIntProperty',
                icon: Icons.groups_2_outlined,
                accentColor: SpaceMissionTheme.highlight,
                value: '${viewModel.crewCount.value} specialists',
                originalValue:
                    '${viewModel.crewCount.originalValue} specialists',
                dirty: viewModel.crewCount.isDirty,
                onPressed: viewModel.cycleCrewCount,
                actionLabel: 'Cycle crew',
              ),
              _TelemetryCard(
                title: 'Thrust Output',
                subtitle: 'CurrentDoubleProperty',
                icon: Icons.speed_outlined,
                accentColor: SpaceMissionTheme.warning,
                value: '${viewModel.thrust.value.toStringAsFixed(1)}%',
                originalValue:
                    '${viewModel.thrust.originalValue.toStringAsFixed(1)}%',
                dirty: viewModel.thrust.isDirty,
                onPressed: viewModel.boostThrust,
                actionLabel: 'Boost 4.5%',
              ),
              _TelemetryCard(
                title: 'Autopilot State',
                subtitle: 'CurrentBoolProperty',
                icon: Icons.toggle_on_outlined,
                accentColor: SpaceMissionTheme.accentStrong,
                value: viewModel.autopilotArmed.isTrue
                    ? 'Armed'
                    : 'Manual override',
                originalValue: viewModel.autopilotArmed.originalValue
                    ? 'Armed'
                    : 'Manual override',
                dirty: viewModel.autopilotArmed.isDirty,
                onPressed: viewModel.toggleAutopilot,
                actionLabel: viewModel.autopilotArmed.isTrue
                    ? 'Switch to manual'
                    : 'Arm autopilot',
              ),
              _TelemetryCard(
                title: 'Next Burn Window',
                subtitle: 'CurrentDateTimeProperty',
                icon: Icons.event_available_outlined,
                accentColor: SpaceMissionTheme.highlight,
                value: _formatDate(viewModel.nextBurn.value),
                originalValue: _formatDate(viewModel.nextBurn.originalValue),
                dirty: viewModel.nextBurn.isDirty,
                onPressed: viewModel.delayBurn,
                actionLabel: 'Delay burn 90 min',
              ),
            ],
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
    return '${value.year}-$month-$day  $hour:$minute UTC';
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MissionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: SpaceMissionTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(value, style: textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(
            'Original baseline: $originalValue',
            style: textTheme.bodyMedium?.copyWith(
              color: SpaceMissionTheme.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          StatusPill(
            label: dirty ? 'Dirty' : 'Baseline match',
            icon: dirty ? Icons.edit_note_outlined : Icons.check_circle_outline,
            color:
                dirty ? SpaceMissionTheme.warning : SpaceMissionTheme.highlight,
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
