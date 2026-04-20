import 'package:current/current.dart';
import 'package:current_counter_example/components/mission_section.dart';

class ApplicationViewModel extends CurrentViewModel {
  final selectedSectionIndex = CurrentProperty.integer(
    initialValue: 0,
    propertyName: 'selectedSection',
  );

  final starfieldEnabled = CurrentProperty.boolean(
    initialValue: true,
    propertyName: 'starfieldEnabled',
  );

  final missionStatus = CurrentProperty.string(
    initialValue: 'All systems nominal. Current is tracking every signal.',
    propertyName: 'missionStatus',
  );

  @override
  Iterable<CurrentProperty> get currentProps => [
        selectedSectionIndex,
        starfieldEnabled,
        missionStatus,
      ];

  MissionSection get selectedSection =>
      MissionSection.values[selectedSectionIndex.value];

  void selectSection(MissionSection section) {
    selectedSectionIndex.value = section.index;
    missionStatus.value = switch (section) {
      MissionSection.overview =>
        'Mission control online. Review every Current capability at a glance.',
      MissionSection.telemetry =>
        'Telemetry is streaming through typed CurrentProperty values.',
      MissionSection.flightForms =>
        'Launch approval is running through CurrentTextController and validation.',
      MissionSection.starMap =>
        'Orbital inventory is reacting through list and map properties.',
      MissionSection.launchEvents =>
        'Mission event handlers are listening for milestones, busy states, and anomalies.',
      MissionSection.codeExamples =>
        'Reference snippets are online to show how Current features fit together in code.',
    };
  }

  void toggleStarfield() {
    starfieldEnabled.value = !starfieldEnabled.value;
  }
}
