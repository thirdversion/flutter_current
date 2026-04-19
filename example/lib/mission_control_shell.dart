import 'package:current/current.dart';
import 'package:flutter/material.dart';

import 'application_view_model.dart';
import 'mission_control_theme.dart';
import 'modules/flight_forms_page.dart';
import 'modules/launch_events_page.dart';
import 'modules/mission_overview_page.dart';
import 'modules/star_map_page.dart';
import 'modules/telemetry_lab_page.dart';
import 'view_models/flight_forms_view_model.dart';
import 'view_models/launch_events_view_model.dart';
import 'view_models/star_map_view_model.dart';
import 'view_models/telemetry_lab_view_model.dart';

class MissionControlShell extends CurrentWidget<ApplicationViewModel> {
  const MissionControlShell({super.key, required super.viewModel});

  @override
  CurrentState<MissionControlShell, ApplicationViewModel> createCurrent() {
    return _MissionControlShellState(viewModel);
  }
}

class _MissionControlShellState
    extends CurrentState<MissionControlShell, ApplicationViewModel> {
  _MissionControlShellState(super.viewModel);

  late final List<Widget> _pages = [
    const MissionOverviewPage(),
    TelemetryLabPage(viewModel: TelemetryLabViewModel()),
    FlightFormsPage(viewModel: FlightFormsViewModel()),
    StarMapPage(viewModel: StarMapViewModel()),
    LaunchEventsPage(viewModel: LaunchEventsViewModel()),
  ];

  @override
  Widget build(BuildContext context) {
    final section = viewModel.selectedSection;
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 980;

    return Scaffold(
      body: SpaceBackdrop(
        showStarfield: viewModel.starfieldEnabled.value,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 16 : 24,
              compact ? 16 : 20,
              compact ? 16 : 24,
              compact ? 16 : 24,
            ),
            child: Column(
              children: [
                _ShellHeader(
                  section: section,
                  compact: compact,
                  missionStatus: viewModel.missionStatus.value,
                  starfieldEnabled: viewModel.starfieldEnabled.value,
                  onToggleStarfield: viewModel.toggleStarfield,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: compact
                      ? Column(
                          children: [
                            Expanded(
                                child: _MissionViewport(
                                    section: section, pages: _pages)),
                            const SizedBox(height: 14),
                            _CompactNavigation(
                              section: section,
                              onSelect: (index) => viewModel.selectSection(
                                MissionSection.values[index],
                              ),
                            ),
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _SectionRail(
                              selectedSection: section,
                              onSelect: viewModel.selectSection,
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _MissionViewport(
                                  section: section, pages: _pages),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 14),
                const MissionFooterAttribution(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({
    required this.section,
    required this.compact,
    required this.missionStatus,
    required this.starfieldEnabled,
    required this.onToggleStarfield,
  });

  final MissionSection section;
  final bool compact;
  final String missionStatus;
  final bool starfieldEnabled;
  final VoidCallback onToggleStarfield;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MissionPanel(
      padding: EdgeInsets.all(compact ? 18 : 22),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CurrentBrandMark(height: 34),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        section.title,
                        style: textTheme.titleLarge,
                      ),
                    ),
                    IconButton.outlined(
                      onPressed: onToggleStarfield,
                      icon: Icon(
                        starfieldEnabled
                            ? Icons.auto_awesome
                            : Icons.auto_awesome_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(section.subtitle, style: textTheme.bodyMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    const StatusPill(
                      label: 'Current Mission Control',
                      icon: Icons.rocket_launch_outlined,
                    ),
                    StatusPill(
                      label: starfieldEnabled
                          ? 'Constellations Online'
                          : 'Constellations Muted',
                      icon: Icons.stars,
                      color: starfieldEnabled
                          ? SpaceMissionTheme.highlight
                          : SpaceMissionTheme.textMuted,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  missionStatus,
                  style: textTheme.bodyMedium?.copyWith(
                    color: SpaceMissionTheme.textMuted,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CurrentBrandMark(expanded: true, height: 48),
                    const SizedBox(height: 14),
                    Text(section.title, style: textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      section.subtitle,
                      style: textTheme.bodyLarge?.copyWith(
                        color: SpaceMissionTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          const StatusPill(
                            label: 'Current Mission Control',
                            icon: Icons.travel_explore,
                          ),
                          StatusPill(
                            label: starfieldEnabled
                                ? 'Constellations Online'
                                : 'Constellations Muted',
                            icon: Icons.stars,
                            color: starfieldEnabled
                                ? SpaceMissionTheme.highlight
                                : SpaceMissionTheme.textMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        missionStatus,
                        textAlign: TextAlign.right,
                        style: textTheme.bodyMedium?.copyWith(
                          color: SpaceMissionTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      FilledButton.tonalIcon(
                        onPressed: onToggleStarfield,
                        icon: Icon(
                          starfieldEnabled
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        label: Text(
                          starfieldEnabled
                              ? 'Mute starfield'
                              : 'Restore starfield',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SectionRail extends StatelessWidget {
  const _SectionRail({
    required this.selectedSection,
    required this.onSelect,
  });

  final MissionSection selectedSection;
  final ValueChanged<MissionSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return MissionPanel(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
      child: NavigationRail(
        backgroundColor: Colors.transparent,
        selectedIndex: selectedSection.index,
        onDestinationSelected: (index) =>
            onSelect(MissionSection.values[index]),
        labelType: NavigationRailLabelType.all,
        groupAlignment: -0.9,
        leading: const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: CurrentBrandMark(height: 30),
        ),
        destinations: MissionSection.values
            .map(
              (section) => NavigationRailDestination(
                icon: Icon(section.icon),
                selectedIcon: Icon(section.icon),
                label: Text(section.title),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CompactNavigation extends StatelessWidget {
  const _CompactNavigation({
    required this.section,
    required this.onSelect,
  });

  final MissionSection section;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return MissionPanel(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: NavigationBar(
        backgroundColor: Colors.transparent,
        selectedIndex: section.index,
        onDestinationSelected: onSelect,
        destinations: MissionSection.values
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                label: item.title,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _MissionViewport extends StatelessWidget {
  const _MissionViewport({
    required this.section,
    required this.pages,
  });

  final MissionSection section;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return MissionPanel(
      padding: EdgeInsets.zero,
      color: SpaceMissionTheme.panelStrong,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: IndexedStack(
          index: section.index,
          children: pages,
        ),
      ),
    );
  }
}
