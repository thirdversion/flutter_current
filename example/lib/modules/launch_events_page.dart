import 'package:current/current.dart';
import 'package:flutter/material.dart';

import '../mission_control_theme.dart';

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

class LaunchEventsViewModel extends CurrentViewModel {
  static const diagnosticsTask = 'diagnostics';

  final countdown = CurrentProperty.integer(
    initialValue: 10,
    propertyName: 'countdown',
  );
  final autoAbortArmed = CurrentProperty.boolean(
    initialValue: true,
    propertyName: 'autoAbortArmed',
  );
  final launchState = CurrentProperty.string(
    initialValue: 'Standing by for launch sequence.',
    propertyName: 'launchState',
  );
  final activityLog = CurrentProperty.list<String>(
    initialValue: ['[Mission Control] Standing by for launch sequence.'],
    propertyName: 'activityLog',
  );

  @override
  Iterable<CurrentProperty> get currentProps => [
        countdown,
        autoAbortArmed,
        launchState,
        activityLog,
      ];

  Future<void> runDiagnostics() async {
    await doAsync(
      () async {
        _appendLog('Running deep-space diagnostics.');
        launchState.value = 'Diagnostics in progress';
        await Future<void>.delayed(const Duration(milliseconds: 450));
        notifyChange(LaunchMilestoneEvent(
          property: countdown,
          label: 'Telemetry lock acquired',
        ));
        _appendLog('Telemetry lock acquired.');
        await Future<void>.delayed(const Duration(milliseconds: 450));
        _appendLog('Flight computer returned nominal.');
        launchState.value = 'Diagnostics complete';
      },
      busyTaskKey: diagnosticsTask,
    );
  }

  void advanceCountdown() {
    if (countdown.value == 0) {
      _appendLog('Ignition already reached. Reset the sequence to run again.');
      return;
    }

    countdown.decrement();
    launchState.value = 'Countdown at T-${countdown.value}';
    _appendLog('Countdown advanced to T-${countdown.value}.');

    if (countdown.value == 5) {
      notifyChange(LaunchMilestoneEvent(
        property: countdown,
        label: 'Go/No-Go poll completed',
      ));
    }

    if (countdown.value == 0) {
      notifyChange(LaunchMilestoneEvent(
        property: countdown,
        label: 'Main engine ignition',
      ));
      launchState.value = 'Ignition confirmed';
      _appendLog('Main engine ignition confirmed.');
    }
  }

  void toggleAutoAbort() {
    autoAbortArmed.value = !autoAbortArmed.value;
    _appendLog(
      autoAbortArmed.value
          ? 'Auto-abort safeguards armed.'
          : 'Auto-abort safeguards shifted to manual override.',
    );
  }

  void simulateAnomaly() {
    notifyError(MissionAnomalyEvent('Solar flare detected on relay alpha.'));
    launchState.value = 'Anomaly raised';
    _appendLog('Anomaly raised for relay alpha.');
  }

  void resetSequence() {
    resetAll();
  }

  void _appendLog(String entry) {
    activityLog.insert(0, '[Mission Control] $entry');
  }
}

class LaunchMilestoneEvent extends CurrentStateChanged<String> {
  LaunchMilestoneEvent({
    required CurrentProperty property,
    required String label,
  }) : super(
          label,
          null,
          propertyName: property.propertyName,
          description: 'Launch Milestone',
          sourceHashCode: property.sourceHashCode,
        );
}

class MissionAnomalyEvent extends ErrorEvent<String> {
  MissionAnomalyEvent(super.error);
}
