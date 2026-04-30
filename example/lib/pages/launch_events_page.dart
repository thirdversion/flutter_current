import 'package:current/current.dart';
import 'package:mission_control_example/space_mission_theme.dart';
import 'package:flutter/material.dart';

import '../components/mission_control_theme.dart';
import '../view_models/launch_events_view_model.dart';

class LaunchEventsPage extends CurrentWidget<LaunchEventsViewModel> {
  const LaunchEventsPage({super.key, required super.viewModel});

  @override
  CurrentState<LaunchEventsPage, LaunchEventsViewModel> createCurrent() {
    return _LaunchEventsPageState(viewModel);
  }
}

class _LaunchEventsPageState
    extends CurrentState<LaunchEventsPage, LaunchEventsViewModel> {
  _LaunchEventsPageState(super.viewModel);

  @override
  void initState() {
    super.initState();

    viewModel.addStateChangedListener<LaunchMilestoneEvent>((event) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(event.nextValue ?? 'Milestone reached'),
        ),
      );
    });

    viewModel.addBusyStatusChangedListener(
      (event) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              event.isBusy
                  ? 'Diagnostics are running through Current.doAsync.'
                  : 'Diagnostics completed and busy state cleared.',
            ),
          ),
        );
      },
      busyTaskKey: LaunchEventsViewModel.diagnosticsTask,
    );

    viewModel.addOnErrorEventListener<MissionAnomalyEvent>((event) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: SpaceMissionTheme.danger,
          content: Text(event.error),
        ),
      );
    });

    viewModel.addAnyStateChangedListener(
      (event) {
        final nextValue = event.nextValue;
        if (!mounted || nextValue is! int || nextValue > 3 || nextValue < 0) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Filtered listener: countdown has reached T-$nextValue.'),
          ),
        );
      },
      propertyName: 'countdown',
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 500;
    final runningDiagnostics =
        viewModel.isTaskInProgress(LaunchEventsViewModel.diagnosticsTask);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionPanel(
            padding: EdgeInsets.all(isMobile ? 12 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Launch Events',
                  style: isMobile
                      ? Theme.of(context).textTheme.titleLarge
                      : Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Custom events, busy-state listeners, and error events.',
                  style: (isMobile
                          ? Theme.of(context).textTheme.bodySmall
                          : Theme.of(context).textTheme.bodyMedium)
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
                        label: viewModel.launchState.value,
                        icon: Icons.radar_outlined,
                        color: runningDiagnostics
                            ? SpaceMissionTheme.warning
                            : SpaceMissionTheme.accent,
                        compact: isMobile,
                      ),
                      StatusPill(
                        label: 'T-${viewModel.countdown.value}',
                        icon: Icons.timer_outlined,
                        color: SpaceMissionTheme.highlight,
                        compact: isMobile,
                      ),
                      StatusPill(
                        label: viewModel.autoAbortArmed.isTrue
                            ? 'Auto-abort'
                            : 'Idle',
                        icon: Icons.shield_outlined,
                        color: viewModel.autoAbortArmed.isTrue
                            ? SpaceMissionTheme.highlight
                            : SpaceMissionTheme.textMuted,
                        compact: isMobile,
                      ),
                    ],
                  ),
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
                  onPressed:
                      runningDiagnostics ? null : viewModel.runDiagnostics,
                  icon: runningDiagnostics
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.memory_outlined),
                  label: const Text('Diagnostics'),
                ),
                const SizedBox(height: 6),
                FilledButton.tonalIcon(
                  onPressed: viewModel.advanceCountdown,
                  icon: const Icon(Icons.skip_next_outlined),
                  label: const Text('Advance'),
                ),
                const SizedBox(height: 6),
                FilledButton.tonalIcon(
                  onPressed: viewModel.toggleAutoAbort,
                  icon: const Icon(Icons.security_update_good_outlined),
                  label: const Text('Auto-abort'),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: viewModel.simulateAnomaly,
                  icon: const Icon(Icons.warning_amber_outlined),
                  label: const Text('Anomaly'),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: viewModel.resetSequence,
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
                  onPressed:
                      runningDiagnostics ? null : viewModel.runDiagnostics,
                  icon: runningDiagnostics
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.memory_outlined),
                  label: const Text('Run diagnostics'),
                ),
                FilledButton.tonalIcon(
                  onPressed: viewModel.advanceCountdown,
                  icon: const Icon(Icons.skip_next_outlined),
                  label: const Text('Advance countdown'),
                ),
                FilledButton.tonalIcon(
                  onPressed: viewModel.toggleAutoAbort,
                  icon: const Icon(Icons.security_update_good_outlined),
                  label: const Text('Toggle auto-abort'),
                ),
                OutlinedButton.icon(
                  onPressed: viewModel.simulateAnomaly,
                  icon: const Icon(Icons.warning_amber_outlined),
                  label: const Text('Trigger anomaly'),
                ),
                OutlinedButton.icon(
                  onPressed: viewModel.resetSequence,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reset sequence'),
                ),
              ],
            ),
          const SizedBox(height: 12),
          MissionPanel(
            padding: EdgeInsets.all(isMobile ? 12 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mission activity log',
                  style: isMobile
                      ? Theme.of(context).textTheme.titleSmall
                      : Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Event log powered by CurrentListProperty.',
                  style: (isMobile
                          ? Theme.of(context).textTheme.bodySmall
                          : Theme.of(context).textTheme.bodyMedium)
                      ?.copyWith(
                    color: SpaceMissionTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                if (viewModel.activityLog.value.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No activity yet',
                      style: (isMobile
                              ? Theme.of(context).textTheme.bodySmall
                              : Theme.of(context).textTheme.bodyMedium)
                          ?.copyWith(
                        color: SpaceMissionTheme.textMuted,
                      ),
                    ),
                  )
                else
                  ...viewModel.activityLog.value.map(
                    (entry) => Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: isMobile ? 8 : 10),
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                        border: Border.all(color: SpaceMissionTheme.border),
                      ),
                      child: Text(
                        entry,
                        style: isMobile
                            ? Theme.of(context).textTheme.bodySmall
                            : Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
