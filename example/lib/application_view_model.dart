import 'package:current/current.dart';
import 'package:flutter/material.dart';

enum MissionSection {
  overview,
  telemetry,
  flightForms,
  starMap,
  launchEvents,
}

extension MissionSectionMetadata on MissionSection {
  String get title {
    switch (this) {
      case MissionSection.overview:
        return 'Mission Overview';
      case MissionSection.telemetry:
        return 'Telemetry Lab';
      case MissionSection.flightForms:
        return 'Flight Forms';
      case MissionSection.starMap:
        return 'Star Map Collections';
      case MissionSection.launchEvents:
        return 'Launch Events';
    }
  }

  String get subtitle {
    switch (this) {
      case MissionSection.overview:
        return 'See how Current fits together in one orbital command deck.';
      case MissionSection.telemetry:
        return 'Primitive property types rendered as live spacecraft telemetry.';
      case MissionSection.flightForms:
        return 'CurrentTextController and CurrentValidation powering launch approval.';
      case MissionSection.starMap:
        return 'Collection properties tracking planets, cargo, and mission assets.';
      case MissionSection.launchEvents:
        return 'Busy states, custom events, filtered listeners, and anomaly handling.';
    }
  }

  IconData get icon {
    switch (this) {
      case MissionSection.overview:
        return Icons.radar_outlined;
      case MissionSection.telemetry:
        return Icons.speed_outlined;
      case MissionSection.flightForms:
        return Icons.fact_check_outlined;
      case MissionSection.starMap:
        return Icons.public_outlined;
      case MissionSection.launchEvents:
        return Icons.rocket_launch_outlined;
    }
  }
}

class ApplicationViewModel extends CurrentViewModel {
  final selectedSectionIndex =
      CurrentProperty.integer(initialValue: 0, propertyName: 'selectedSection');
  final starfieldEnabled = CurrentProperty.boolean(
      initialValue: true, propertyName: 'starfieldEnabled');
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
    };
  }

  void toggleStarfield() {
    starfieldEnabled.value = !starfieldEnabled.value;
  }
}
