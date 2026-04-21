import 'package:current/current.dart';
import 'package:current_counter_example/space_mission_theme.dart';
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
    final runningDiagnostics =
        viewModel.isTaskInProgress(LaunchEventsViewModel.diagnosticsTask);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Launch Events',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                Text(
                  'This mission deck demonstrates custom CurrentStateChanged events, busy-state listeners, filtered property listeners, and dedicated error events. Use the controls to drive the timeline below.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: SpaceMissionTheme.textMuted,
                      ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    StatusPill(
                      label: viewModel.launchState.value,
                      icon: Icons.radar_outlined,
                      color: runningDiagnostics
                          ? SpaceMissionTheme.warning
                          : SpaceMissionTheme.accent,
                    ),
                    StatusPill(
                      label: 'Countdown T-${viewModel.countdown.value}',
                      icon: Icons.timer_outlined,
                      color: SpaceMissionTheme.highlight,
                    ),
                    StatusPill(
                      label: viewModel.autoAbortArmed.isTrue
                          ? 'Auto-abort armed'
                          : 'Auto-abort idle',
                      icon: Icons.shield_outlined,
                      color: viewModel.autoAbortArmed.isTrue
                          ? SpaceMissionTheme.highlight
                          : SpaceMissionTheme.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: runningDiagnostics ? null : viewModel.runDiagnostics,
                icon: runningDiagnostics
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
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
          const SizedBox(height: 20),
          MissionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mission activity log',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'The log is just another CurrentListProperty. The snackbars you see come from event subscriptions registered on this page.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SpaceMissionTheme.textMuted,
                      ),
                ),
                const SizedBox(height: 16),
                ...viewModel.activityLog.value.map(
                  (entry) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: SpaceMissionTheme.border),
                    ),
                    child: Text(entry),
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
