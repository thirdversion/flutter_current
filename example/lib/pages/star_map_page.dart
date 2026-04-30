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
    final isMobile = width < 500;
    final isTablet = width < 1120;

    final content = [
      _buildRoutePanel(context, isMobile),
      _buildManifestPanel(context, isMobile),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile
          ? 12
          : isTablet
              ? 14
              : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionPanel(
            padding: EdgeInsets.all(isMobile ? 12 : 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Star Map Collections',
                  style: isMobile
                      ? Theme.of(context).textTheme.titleLarge
                      : Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'CurrentListProperty and CurrentMapProperty with collection-aware events and reset semantics.',
                  style: (isMobile
                          ? Theme.of(context).textTheme.bodySmall
                          : Theme.of(context).textTheme.bodyMedium)
                      ?.copyWith(
                    color: SpaceMissionTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: isMobile ? 6 : 10,
                    runSpacing: 6,
                    children: [
                      StatusPill(
                        label: '${viewModel.routePlan.length} waypoints',
                        icon: Icons.alt_route_outlined,
                        color: SpaceMissionTheme.highlight,
                        compact: isMobile,
                      ),
                      StatusPill(
                        label: '${viewModel.cargoManifest.length} cargo',
                        icon: Icons.inventory_2_outlined,
                        color: SpaceMissionTheme.accent,
                        compact: isMobile,
                      ),
                      StatusPill(
                        label: viewModel.isDirty ? 'Changed' : 'Synced',
                        icon: viewModel.isDirty
                            ? Icons.edit_note_outlined
                            : Icons.check_circle_outline,
                        color: viewModel.isDirty
                            ? SpaceMissionTheme.warning
                            : SpaceMissionTheme.highlight,
                        compact: isMobile,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 10 : 14),
          isTablet
              ? Column(
                  children: [
                    content[0],
                    SizedBox(height: isMobile ? 10 : 14),
                    content[1],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: content[0]),
                    const SizedBox(width: 14),
                    Expanded(child: content[1]),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildRoutePanel(BuildContext context, bool isMobile) {
    return MissionPanel(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Route plan',
            style: isMobile
                ? Theme.of(context).textTheme.titleSmall
                : Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'CurrentListProperty with collection-aware events.',
            style: (isMobile
                    ? Theme.of(context).textTheme.bodySmall
                    : Theme.of(context).textTheme.bodyMedium)
                ?.copyWith(
              color: SpaceMissionTheme.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          if (viewModel.routePlan.value.isNotEmpty)
            Wrap(
              spacing: isMobile ? 6 : 8,
              runSpacing: 6,
              children: viewModel.routePlan.value
                  .map(
                    (planet) => Chip(
                      avatar: Icon(
                        Icons.public,
                        size: isMobile ? 16 : 18,
                      ),
                      label: Text(
                        planet,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                        ),
                      ),
                      onDeleted: () => viewModel.routePlan.remove(planet),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 6 : 8,
                        vertical: isMobile ? 4 : 6,
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No waypoints yet',
                style: (isMobile
                        ? Theme.of(context).textTheme.bodySmall
                        : Theme.of(context).textTheme.bodyMedium)
                    ?.copyWith(
                  color: SpaceMissionTheme.textMuted,
                ),
              ),
            ),
          const SizedBox(height: 10),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.tonalIcon(
                  onPressed: viewModel.addNextPlanet,
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Add world'),
                ),
                const SizedBox(height: 6),
                FilledButton.tonalIcon(
                  onPressed: viewModel.addSurveyCluster,
                  icon: const Icon(Icons.hub_outlined),
                  label: const Text('Add cluster'),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: viewModel.routePlan.isNotEmpty
                      ? viewModel.removeLastPlanet
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  label: const Text('Remove last'),
                ),
              ],
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
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

  Widget _buildManifestPanel(BuildContext context, bool isMobile) {
    return MissionPanel(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cargo manifest',
            style: isMobile
                ? Theme.of(context).textTheme.titleSmall
                : Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'CurrentMapProperty with in-place mutations.',
            style: (isMobile
                    ? Theme.of(context).textTheme.bodySmall
                    : Theme.of(context).textTheme.bodyMedium)
                ?.copyWith(
              color: SpaceMissionTheme.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          if (viewModel.cargoManifest.entries.isNotEmpty)
            Column(
              children: viewModel.cargoManifest.entries
                  .map(
                    (entry) => Container(
                      margin: EdgeInsets.only(bottom: isMobile ? 8 : 10),
                      padding: EdgeInsets.all(isMobile ? 10 : 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                        border: Border.all(color: SpaceMissionTheme.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.key,
                                  style: isMobile
                                      ? Theme.of(context).textTheme.titleSmall
                                      : Theme.of(context).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry.value,
                                  style: (isMobile
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                          : Theme.of(context)
                                              .textTheme
                                              .bodyMedium)
                                      ?.copyWith(
                                    color: SpaceMissionTheme.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () =>
                                  viewModel.cargoManifest.remove(entry.key),
                              icon: const Icon(Icons.delete_outline),
                              iconSize: isMobile ? 18 : 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No cargo yet',
                style: (isMobile
                        ? Theme.of(context).textTheme.bodySmall
                        : Theme.of(context).textTheme.bodyMedium)
                    ?.copyWith(
                  color: SpaceMissionTheme.textMuted,
                ),
              ),
            ),
          const SizedBox(height: 10),
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.tonalIcon(
                  onPressed: viewModel.addNextCargoModule,
                  icon: const Icon(Icons.add_box_outlined),
                  label: const Text('Add cargo'),
                ),
                const SizedBox(height: 6),
                FilledButton.tonalIcon(
                  onPressed: viewModel.rebalanceManifest,
                  icon: const Icon(Icons.swap_horiz_outlined),
                  label: const Text('Rebalance'),
                ),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: viewModel.resetAll,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reset'),
                ),
              ],
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
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
