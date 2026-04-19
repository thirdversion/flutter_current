import 'package:current/current.dart';

class FlightFormsViewModel extends CurrentViewModel {
  final missionCode = CurrentProperty.string(
    initialValue: '',
    propertyName: 'missionCode',
  );
  final crewCapacity = CurrentProperty.integer(
    initialValue: 0,
    propertyName: 'crewCapacity',
  );
  final launchWindow = CurrentProperty.dateTime(
    initialValue: DateTime.now().add(const Duration(days: 14)),
    propertyName: 'launchWindow',
  );
  final submissionStatus = CurrentProperty.string(
    initialValue: 'Awaiting launch authorization.',
    propertyName: 'submissionStatus',
  );

  late final CurrentFieldValidation<String> missionCodeValidation =
      missionCode.createValidation(
    rules: [
      (value) => value.trim().isEmpty ? 'Mission code is required.' : null,
      (value) => value.contains('-') ? null : 'Use a code like ARTEMIS-2.',
      (value) => value.length >= 6
          ? null
          : 'Mission code must be at least 6 characters.',
    ],
    validateOnPropertyChange: true,
  );

  late final CurrentFieldValidation<int> crewCapacityValidation =
      crewCapacity.createValidation(
    rules: [
      (value) => value >= 2 ? null : 'Crew capacity must be at least 2.',
      (value) => value <= 8 ? null : 'Crew capacity must be 8 or fewer.',
    ],
    validateOnPropertyChange: true,
  );

  late final CurrentFieldValidation<DateTime> launchWindowValidation =
      launchWindow.createValidation(
    rules: [
      (value) => value.isAfter(DateTime.now().add(const Duration(days: 2)))
          ? null
          : 'Launch window must be at least 48 hours from now.',
    ],
    validateOnPropertyChange: true,
  );

  late final validationGroup = CurrentValidationGroup([
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
  Iterable<CurrentViewModelBinding> get currentBindings => [
        missionCodeValidation,
        crewCapacityValidation,
        launchWindowValidation,
      ];

  bool authorizeLaunch() {
    final isReady = validationGroup.validateAll();

    submissionStatus.value = isReady
        ? 'Launch package approved for ignition.'
        : validationGroup.firstErrorText ??
            'Launch package still has open validation issues.';

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
