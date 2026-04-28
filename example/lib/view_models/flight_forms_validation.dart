import 'package:current/current.dart';

const missionCodeRequiredIssue = CurrentValidationIssue(
  'flightForms.missionCode.required',
);

const missionCodeFormatIssue = CurrentValidationIssue(
  'flightForms.missionCode.format',
);

const missionCodeLengthIssue = CurrentValidationIssue(
  'flightForms.missionCode.length',
  arguments: {'minimumLength': 6},
);

const crewCapacityMinimumIssue = CurrentValidationIssue(
  'flightForms.crewCapacity.minimum',
  arguments: {'minimumCrew': 2},
);

const crewCapacityMaximumIssue = CurrentValidationIssue(
  'flightForms.crewCapacity.maximum',
  arguments: {'maximumCrew': 8},
);

const launchWindowMinimumIssue = CurrentValidationIssue(
  'flightForms.launchWindow.minimumLeadTime',
  arguments: {'minimumHours': 48},
);

Iterable<CurrentValidationRule<String>> missionCodeRules() {
  return [
    (value) => value.trim().isEmpty ? missionCodeRequiredIssue : null,
    (value) => value.contains('-') ? null : missionCodeFormatIssue,
    (value) => value.length >= 6 ? null : missionCodeLengthIssue,
  ];
}

Iterable<CurrentValidationRule<int>> crewCapacityRules() {
  return [
    (value) => value >= 2 ? null : crewCapacityMinimumIssue,
    (value) => value <= 8 ? null : crewCapacityMaximumIssue,
  ];
}

Iterable<CurrentValidationRule<DateTime>> launchWindowRules() {
  return [
    (value) => value.isAfter(DateTime.now().add(const Duration(days: 2)))
        ? null
        : launchWindowMinimumIssue,
  ];
}
