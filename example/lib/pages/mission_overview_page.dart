import 'package:current/current.dart';
import 'package:mission_control_example/extensions.dart';
import 'package:mission_control_example/components/mission_section.dart';
import 'package:mission_control_example/space_mission_theme.dart';
import 'package:flutter/material.dart';

import '../application_view_model.dart';
import '../components/mission_control_theme.dart';

class MissionOverviewPage extends StatelessWidget {
  const MissionOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appViewModel = Current.viewModelOf<ApplicationViewModel>(context);
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 500;
    final isTablet = width < 960;
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
      padding: EdgeInsets.all(isMobile
          ? 12
          : isTablet
              ? 16
              : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MissionPanel(
            padding: EdgeInsets.all(isMobile
                ? 14
                : isTablet
                    ? 18
                    : 24),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CurrentBrandMark(expanded: true, height: 40),
                      const SizedBox(height: 12),
                      Text(
                        'Orbit every Current feature from one mission deck.',
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'This example shows how Current handles state, forms, validation, collections, and events.',
                        style: textTheme.bodySmall?.copyWith(
                          color: SpaceMissionTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => appViewModel
                              .selectSection(MissionSection.flightForms),
                          icon: const Icon(Icons.fact_check_outlined),
                          label: const Text('Launch approval'),
                        ),
                      ),
                    ],
                  )
                : isTablet
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CurrentBrandMark(expanded: true, height: 48),
                          const SizedBox(height: 14),
                          Text(
                            'Orbit every Current feature from one mission deck.',
                            style: textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'This example replaces the starter counter with a space mission dashboard that shows how Current handles state, forms, validation, collections, events, and async feedback.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: SpaceMissionTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: const [
                              StatusPill(
                                label: '5 modules',
                                icon: Icons.dashboard_customize_outlined,
                              ),
                              StatusPill(
                                label: 'Validation + binding',
                                icon: Icons.rule_folder_outlined,
                                color: SpaceMissionTheme.highlight,
                              ),
                              StatusPill(
                                label: 'Pure state',
                                icon: Icons.layers_clear_outlined,
                                color: SpaceMissionTheme.warning,
                              ),
                            ],
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const CurrentBrandMark(expanded: true, height: 64),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Orbit every Current feature from one mission deck.',
                                  style: textTheme.displaySmall,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Current keeps Flutter state readable without sacrificing power. This mission-control example shows the library at production scale: typed properties, validation metadata, text binding, collection semantics, event streams, busy states, and reset workflows.',
                                  style: textTheme.bodyLarge?.copyWith(
                                    color: SpaceMissionTheme.textMuted,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
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
          SizedBox(
              height: isMobile
                  ? 12
                  : isTablet
                      ? 14
                      : 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = isMobile
                  ? double.infinity
                  : isTablet
                      ? (constraints.maxWidth - 12) / 2
                      : 380.0;

              return Wrap(
                spacing: isMobile ? 12 : 14,
                runSpacing: isMobile ? 12 : 14,
                children: cards
                    .map(
                      (card) => SizedBox(
                        width: cardWidth,
                        child: MissionPanel(
                          padding: EdgeInsets.all(isMobile ? 12 : 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(isMobile ? 8 : 10),
                                    decoration: BoxDecoration(
                                      color: SpaceMissionTheme.accentStrong
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(
                                          isMobile ? 14 : 16),
                                    ),
                                    child: Icon(
                                      card.section.icon,
                                      size: isMobile ? 18 : 20,
                                      color: SpaceMissionTheme.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      card.title,
                                      style: isMobile
                                          ? textTheme.titleSmall
                                          : textTheme.titleMedium,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                card.description,
                                style: (isMobile
                                        ? textTheme.bodySmall
                                        : textTheme.bodyMedium)
                                    ?.copyWith(
                                  color: SpaceMissionTheme.textMuted,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...card.bulletPoints.map(
                                (bullet) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Icon(
                                          Icons.arrow_outward,
                                          size: 12,
                                          color: SpaceMissionTheme.highlight,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          bullet,
                                          style: isMobile
                                              ? textTheme.bodySmall
                                              : textTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.tonalIcon(
                                  onPressed: () =>
                                      appViewModel.selectSection(card.section),
                                  icon: Icon(
                                    card.section.icon,
                                    size: isMobile ? 18 : 20,
                                  ),
                                  label: Text(
                                    isMobile
                                        ? card.section.title
                                        : 'Open ${card.section.title}',
                                    style: TextStyle(
                                      fontSize: isMobile ? 12 : 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
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
