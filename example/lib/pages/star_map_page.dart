import 'package:current/current.dart';
import 'package:mission_control_example/space_mission_theme.dart';
import 'package:flutter/material.dart';

import '../components/mission_control_theme.dart';
import '../view_models/star_map_view_model.dart';

class StarMapPage extends CurrentWidget<StarMapViewModel> {
  const StarMapPage({super.key, required super.viewModel});

  @override
  CurrentState<StarMapPage, StarMapViewModel> createCurrent() {
    return _StarMapPageState(viewModel);
  }
}

class _StarMapPageState extends CurrentState<StarMapPage, StarMapViewModel> {
  _StarMapPageState(super.viewModel);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 1120;

    final content = [
      _buildRoutePanel(context),
      _buildManifestPanel(context),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Star Map Collections',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                Text(
                  'This deck demonstrates why CurrentListProperty and CurrentMapProperty exist separately from the base CurrentProperty type. Collection mutations remain reactive, and reset semantics stay correct without replacing whole lists or maps by hand.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: SpaceMissionTheme.textMuted,
                      ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    StatusPill(
                      label: '${viewModel.routePlan.length} waypoints',
                      icon: Icons.alt_route_outlined,
                      color: SpaceMissionTheme.highlight,
                    ),
                    StatusPill(
                      label: '${viewModel.cargoManifest.length} cargo modules',
                      icon: Icons.inventory_2_outlined,
                      color: SpaceMissionTheme.accent,
                    ),
                    StatusPill(
                      label: viewModel.isDirty
                          ? 'Collections changed'
                          : 'Collections synced',
                      icon: viewModel.isDirty
                          ? Icons.edit_note_outlined
                          : Icons.check_circle_outline,
                      color: viewModel.isDirty
                          ? SpaceMissionTheme.warning
                          : SpaceMissionTheme.highlight,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          compact
              ? Column(
                  children: [
                    content[0],
                    const SizedBox(height: 18),
                    content[1],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: content[0]),
                    const SizedBox(width: 18),
                    Expanded(child: content[1]),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildRoutePanel(BuildContext context) {
    return MissionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Route plan', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Powered by CurrentListProperty<String>. Each add, remove, and reset is handled with collection-aware events.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SpaceMissionTheme.textMuted,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: viewModel.routePlan.value
                .map(
                  (planet) => Chip(
                    avatar: const Icon(Icons.public, size: 18),
                    label: Text(planet),
                    onDeleted: () => viewModel.routePlan.remove(planet),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonalIcon(
                onPressed: viewModel.addNextPlanet,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add next world'),
              ),
              FilledButton.tonalIcon(
                onPressed: viewModel.addSurveyCluster,
                icon: const Icon(Icons.hub_outlined),
                label: const Text('Add survey cluster'),
              ),
              OutlinedButton.icon(
                onPressed: viewModel.routePlan.isNotEmpty
                    ? viewModel.removeLastPlanet
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                label: const Text('Remove last'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManifestPanel(BuildContext context) {
    return MissionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cargo manifest', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Powered by CurrentMapProperty<String, String>. Cargo modules are updated in place while listeners still receive correct map-specific event payloads.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: SpaceMissionTheme.textMuted,
                ),
          ),
          const SizedBox(height: 16),
          ...viewModel.cargoManifest.entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SpaceMissionTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.key,
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text(
                          entry.value,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: SpaceMissionTheme.textMuted,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => viewModel.cargoManifest.remove(entry.key),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonalIcon(
                onPressed: viewModel.addNextCargoModule,
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Add cargo module'),
              ),
              FilledButton.tonalIcon(
                onPressed: viewModel.rebalanceManifest,
                icon: const Icon(Icons.swap_horiz_outlined),
                label: const Text('Rebalance manifest'),
              ),
              OutlinedButton.icon(
                onPressed: viewModel.resetAll,
                icon: const Icon(Icons.restart_alt_outlined),
                label: const Text('Reset collections'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
