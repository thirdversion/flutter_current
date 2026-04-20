import 'package:current/current.dart';

import 'flight_forms_validation.dart';

class FlightFormsViewModel extends CurrentViewModel
    with CurrentValidationMixin {
  final missionCode = CurrentProperty.string();
  final crewCapacity = CurrentProperty.integer();
  final launchWindow = CurrentProperty.dateTime(
    initialValue: DateTime.now().add(const Duration(days: 14)),
  );
  final submissionStatus = CurrentProperty.string(
    initialValue: 'Awaiting launch authorization.',
  );

  CurrentFieldValidation<String>? _missionCodeValidation;
  CurrentFieldValidation<String> get missionCodeValidation =>
      _missionCodeValidation ??= missionCode.createValidation(
        rules: missionCodeRules(),
        validateOnPropertyChange: true,
      );

  CurrentFieldValidation<int>? _crewCapacityValidation;
  CurrentFieldValidation<int> get crewCapacityValidation =>
      _crewCapacityValidation ??= crewCapacity.createValidation(
        rules: crewCapacityRules(),
        validateOnPropertyChange: true,
      );

  CurrentFieldValidation<DateTime>? _launchWindowValidation;
  CurrentFieldValidation<DateTime> get launchWindowValidation =>
      _launchWindowValidation ??= launchWindow.createValidation(
        rules: launchWindowRules(),
        validateOnPropertyChange: true,
      );

  CurrentValidationGroup? _validationGroup;
  CurrentValidationGroup get validationGroup =>
      _validationGroup ??= CurrentValidationGroup([
        missionCodeValidation,
        crewCapacityValidation,
        launchWindowValidation,
      ]);

  @override
  Iterable<CurrentProperty> get currentProps => [
        missionCode,
        crewCapacity,
        launchWindow,
        submissionStatus,
      ];

  @override
  Iterable<CurrentFieldValidation> get currentValidations => [
        missionCodeValidation,
        crewCapacityValidation,
        launchWindowValidation,
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
