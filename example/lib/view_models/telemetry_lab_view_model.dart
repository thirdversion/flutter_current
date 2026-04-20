import 'package:current/current.dart';

class TelemetryLabViewModel extends CurrentViewModel {
  TelemetryLabViewModel();

  final missionName = CurrentProperty.string(initialValue: 'Odyssey Relay');
  final crewCount = CurrentProperty.integer(initialValue: 4);
  final thrust = CurrentProperty.doubleProp(initialValue: 72.4);
  final autopilotArmed = CurrentProperty.boolean(initialValue: true);
  final nextBurn = CurrentProperty.dateTime(
    initialValue: DateTime.utc(2042, 7, 16, 14, 45),
  );

  static const _callsigns = [
    'Odyssey Relay',
    'Atlas Horizon',
    'Nova Vector',
    'Dark Side One',
  ];

  @override
  Iterable<CurrentProperty> get currentProps => [
        missionName,
        crewCount,
        thrust,
        autopilotArmed,
        nextBurn,
      ];

  void rotateCallsign() {
    final currentIndex = _callsigns.indexOf(missionName.value);
    final nextIndex =
        currentIndex == -1 ? 0 : (currentIndex + 1) % _callsigns.length;
    missionName.value = _callsigns[nextIndex];
  }

  void cycleCrewCount() {
    crewCount.value = crewCount.value >= 7 ? 3 : crewCount.value + 1;
  }

  void boostThrust() {
    thrust.value = ((thrust.value + 4.5).clamp(10.0, 100.0) as num).toDouble();
  }

  void toggleAutopilot() {
    autopilotArmed.value = !autopilotArmed.value;
  }

  void delayBurn() {
    nextBurn.value = nextBurn.value.add(const Duration(minutes: 90));
  }

  void simulateOrbitalBoost() {
    setMultiple([
      {missionName: 'Astrophage Annihilator'},
      {crewCount: 6},
      {thrust: 88.2},
      {autopilotArmed: true},
      {nextBurn: DateTime.utc(2042, 7, 17, 6, 30)},
    ]);
  }

  void commitBaseline() {
    for (final property in currentProps) {
      property.setOriginalValueToCurrent();
    }
  }
}
