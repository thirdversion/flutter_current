import 'package:current/current.dart';

class FlightFormsViewModel extends CurrentViewModel {
  final missionCode = CurrentProperty.string();
  final crewCapacity = CurrentProperty.integer();
  final launchWindow = CurrentProperty.dateTime(
    initialValue: DateTime.now().add(const Duration(days: 14)),
  );
  final submissionStatus = CurrentProperty.string(
    initialValue: 'Awaiting launch authorization.',
  );

  CurrentValidationGroup? _validationGroup;
  CurrentValidationGroup get validationGroup =>
      _validationGroup ??= CurrentValidationGroup.forProperties([
        missionCode,
        crewCapacity,
        launchWindow,
      ]);

  @override
  Iterable<CurrentProperty> get currentProps => [
        missionCode,
        crewCapacity,
        launchWindow,
        submissionStatus,
      ];

  bool authorizeLaunch() {
    final isReady = validationGroup.validateAll();

    submissionStatus.value = isReady
        ? 'Launch package approved for ignition.'
        : 'Launch package still has open validation issues.';

    return isReady;
  }

  void loadSampleManifest() {
    setMultiple([
      {missionCode: 'ARTEMIS-2'},
      {crewCapacity: 6},
      {launchWindow: DateTime.now().add(const Duration(days: 27))},
    ]);
    submissionStatus.value = 'Sample manifest loaded from mission control.';
  }

  void resetMissionPlan() {
    resetAll();
    validationGroup.resetAll();
  }
}
