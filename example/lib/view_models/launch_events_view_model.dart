import 'package:current/current.dart';

class LaunchEventsViewModel extends CurrentViewModel {
  static const diagnosticsTask = 'diagnostics';

  final countdown = CurrentProperty.integer(initialValue: 10);
  final autoAbortArmed = CurrentProperty.boolean(initialValue: true);
  final launchState = CurrentProperty.string(
    initialValue: 'Standing by for launch sequence.',
  );
  final activityLog = CurrentProperty.list<String>(
    initialValue: ['[Mission Control] Standing by for launch sequence.'],
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
