import 'package:current_counter_example/components/mission_section.dart';
import 'package:flutter/material.dart';

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
