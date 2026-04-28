import 'package:current/current.dart';

class StarMapViewModel extends CurrentViewModel {
  StarMapViewModel();

  final routePlan = CurrentProperty.list<String>(
    initialValue: ['Mercury', 'Venus', 'Earth'],
  );

  final cargoManifest = CurrentProperty.map<String, String>(
    initialValue: {
      'Habitat Ring': 'Stable and pressurized',
      'Sensor Array': 'Calibrating in low orbit',
      'Fuel': '92% capacity',
    },
  );

  static const _planetCatalog = [
    'Mars',
    'Jupiter',
    'Saturn',
    'Uranus',
    'Neptune',
  ];

  static const _cargoModules = {
    'Cryo Pods': 'Crew storage online',
    'Shield Array': 'Thermal shielding aligned',
    'Probe Bay': 'Ready for survey deployment',
    'Relay Drones': 'Queued for launch window sync',
  };

  @override
  Iterable<CurrentProperty> get currentProps => [routePlan, cargoManifest];

  void addNextPlanet() {
    final nextPlanet = _planetCatalog[routePlan.length % _planetCatalog.length];
    routePlan.add(nextPlanet);
  }

  void addSurveyCluster() {
    routePlan.insertAllAtEnd(['Europa', 'Titan']);
  }

  void removeLastPlanet() {
    if (routePlan.isNotEmpty) {
      routePlan.removeAt(routePlan.length - 1);
    }
  }

  void addNextCargoModule() {
    final nextEntry = _cargoModules.entries.firstWhere(
      (entry) => !cargoManifest.containsKey(entry.key),
      orElse: () =>
          const MapEntry('Beacon Net', 'Deep-space relays synchronized'),
    );
    cargoManifest.add(nextEntry.key, nextEntry.value);
  }

  void rebalanceManifest() {
    cargoManifest.updateAll((key, value) => '$value • rebalanced');
  }
}
