import 'package:current/current.dart';
import 'package:current_counter_example/extensions.dart';
import 'package:current_counter_example/components/mission_section.dart';
import 'package:current_counter_example/space_mission_theme.dart';
import 'package:flutter/material.dart';

import '../application_view_model.dart';
import '../components/mission_control_theme.dart';

class MissionOverviewPage extends StatelessWidget {
  const MissionOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appViewModel = Current.viewModelOf<ApplicationViewModel>(context);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 960;
    final textTheme = Theme.of(context).textTheme;

    final cards = [
      _OverviewCardData(
        section: MissionSection.telemetry,
        title: 'Typed telemetry',
        description:
            'Primitive CurrentProperty values drive gauges, toggles, and orbital windows while dirty state and reset behavior stay visible.',
        bulletPoints: const [
          'CurrentIntProperty and CurrentDoubleProperty',
          'CurrentBoolProperty and CurrentDateTimeProperty',
          'Original value, dirty state, and reset cycles',
        ],
      ),
      _OverviewCardData(
        section: MissionSection.flightForms,
        title: 'Launch approval forms',
        description:
            'CurrentTextController and CurrentValidation power a mission form with live parsing, touched state, and aggregate submit readiness.',
        bulletPoints: const [
          'String, int, and date text binding',
          'Field validation + validation groups',
          'Programmatic property updates syncing back to the UI',
        ],
      ),
      _OverviewCardData(
        section: MissionSection.starMap,
        title: 'Reactive collections',
        description:
            'List and map properties render a live star chart of destinations and mission cargo with collection-specific reset semantics.',
        bulletPoints: const [
          'CurrentListProperty for route plans',
          'CurrentMapProperty for cargo manifests',
          'Collection mutation without manual setState',
        ],
      ),
      _OverviewCardData(
        section: MissionSection.launchEvents,
        title: 'Mission event stream',
        description:
            'Custom CurrentStateChanged events, busy state changes, filtered listeners, and error events all appear in one launch control console.',
        bulletPoints: const [
          'Custom event publishing',
          'Busy task tracking',
          'Error event handlers and countdown listeners',
        ],
      ),
      _OverviewCardData(
        section: MissionSection.codeExamples,
        title: 'Reference snippets',
        description:
            'Walk through concise examples that show how to declare a view model, bind fields, validate forms, and react to Current events.',
        bulletPoints: const [
          'CurrentViewModel + CurrentWidget basics',
          'Text binding and validation examples',
          'Collections, busy state, and event listeners',
        ],
      ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(compact ? 20 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionPanel(
            padding: EdgeInsets.all(compact ? 22 : 30),
            child: compact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CurrentBrandMark(expanded: true, height: 54),
                      const SizedBox(height: 18),
                      Text(
                        'Orbit every Current feature from one mission deck.',
                        style: textTheme.displaySmall,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'This example replaces the starter counter with a space mission dashboard that shows how Current handles state, forms, validation, collections, events, and async feedback in a real-feeling interface.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: SpaceMissionTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () => appViewModel
                            .selectSection(MissionSection.flightForms),
                        icon: const Icon(Icons.fact_check_outlined),
                        label: const Text('Open the launch approval flow'),
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CurrentBrandMark(expanded: true, height: 82),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Orbit every Current feature from one mission deck.',
                              style: textTheme.displaySmall,
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Current keeps Flutter state readable without sacrificing power. This mission-control example shows the library at production scale: typed properties, validation metadata, text binding, collection semantics, event streams, busy states, and reset workflows.',
                              style: textTheme.bodyLarge?.copyWith(
                                color: SpaceMissionTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 22),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: const [
                                StatusPill(
                                  label: '6 mission modules',
                                  icon: Icons.dashboard_customize_outlined,
                                ),
                                StatusPill(
                                  label: 'Validation + text binding',
                                  icon: Icons.rule_folder_outlined,
                                  color: SpaceMissionTheme.highlight,
                                ),
                                StatusPill(
                                  label: 'Zero third-party state layer',
                                  icon: Icons.layers_clear_outlined,
                                  color: SpaceMissionTheme.warning,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 18,
            runSpacing: 18,
            children: cards
                .map(
                  (card) => SizedBox(
                    width: compact ? double.infinity : 360,
                    child: MissionPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: SpaceMissionTheme.accentStrong
                                      .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(card.section.icon,
                                    color: SpaceMissionTheme.accent),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(card.title,
                                    style: textTheme.titleLarge),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            card.description,
                            style: textTheme.bodyMedium?.copyWith(
                              color: SpaceMissionTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...card.bulletPoints.map(
                            (bullet) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Icon(
                                      Icons.arrow_outward,
                                      size: 14,
                                      color: SpaceMissionTheme.highlight,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: Text(bullet)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            onPressed: () =>
                                appViewModel.selectSection(card.section),
                            icon: Icon(card.section.icon),
                            label: Text('Open ${card.section.title}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _OverviewCardData {
  const _OverviewCardData({
    required this.section,
    required this.title,
    required this.description,
    required this.bulletPoints,
  });

  final MissionSection section;
  final String title;
  final String description;
  final List<String> bulletPoints;
}
