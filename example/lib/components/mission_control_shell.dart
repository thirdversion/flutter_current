import 'package:current/current.dart';
import 'package:mission_control_example/extensions.dart';
import 'package:mission_control_example/components/mission_section.dart';
import 'package:mission_control_example/space_mission_theme.dart';
import 'package:flutter/material.dart';

import '../application_view_model.dart';
import 'mission_control_theme.dart';
import '../pages/flight_forms_page.dart';
import '../pages/code_examples_page.dart';
import '../pages/launch_events_page.dart';
import '../pages/mission_overview_page.dart';
import '../pages/star_map_page.dart';
import '../pages/telemetry_lab_page.dart';
import '../view_models/flight_forms_view_model.dart';
import '../view_models/launch_events_view_model.dart';
import '../view_models/star_map_view_model.dart';
import '../view_models/telemetry_lab_view_model.dart';

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
    const CodeExamplesPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final section = viewModel.selectedSection;
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 600;
    final isTablet = width < 980;

    return Scaffold(
      body: SpaceBackdrop(
        showStarfield: viewModel.starfieldEnabled.value,
        child: SafeArea(
          child: isMobile
              ? _buildMobileLayout(context, section, viewModel, _pages)
              : isTablet
                  ? _buildTabletLayout(context, section, viewModel, _pages)
                  : _buildDesktopLayout(context, section, viewModel, _pages),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, MissionSection section,
      ApplicationViewModel viewModel, List<Widget> pages) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: _ShellHeader(
            section: section,
            compact: true,
            mobileSize: true,
            missionStatus: viewModel.missionStatus.value,
            starfieldEnabled: viewModel.starfieldEnabled.value,
            onToggleStarfield: viewModel.toggleStarfield,
          ),
        ),
        Expanded(
          child: _MissionViewport(section: section, pages: pages),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: _CompactNavigation(
            section: section,
            onSelect: (index) =>
                viewModel.selectSection(MissionSection.values[index]),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: const _MobileFooterAttribution(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, MissionSection section,
      ApplicationViewModel viewModel, List<Widget> pages) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: _ShellHeader(
            section: section,
            compact: true,
            mobileSize: false,
            missionStatus: viewModel.missionStatus.value,
            starfieldEnabled: viewModel.starfieldEnabled.value,
            onToggleStarfield: viewModel.toggleStarfield,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionRail(
                  selectedSection: section,
                  onSelect: viewModel.selectSection,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MissionViewport(section: section, pages: pages),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: const MissionFooterAttribution(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, MissionSection section,
      ApplicationViewModel viewModel, List<Widget> pages) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _ShellHeader(
            section: section,
            compact: false,
            mobileSize: false,
            missionStatus: viewModel.missionStatus.value,
            starfieldEnabled: viewModel.starfieldEnabled.value,
            onToggleStarfield: viewModel.toggleStarfield,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionRail(
                  selectedSection: section,
                  onSelect: viewModel.selectSection,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _MissionViewport(section: section, pages: pages),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const MissionFooterAttribution(),
        ],
      ),
    );
  }
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({
    required this.section,
    required this.compact,
    required this.mobileSize,
    required this.missionStatus,
    required this.starfieldEnabled,
    required this.onToggleStarfield,
  });

  final MissionSection section;
  final bool compact;
  final bool mobileSize;
  final String missionStatus;
  final bool starfieldEnabled;
  final VoidCallback onToggleStarfield;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (mobileSize) {
      return MissionPanel(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CurrentBrandMark(height: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.title,
                    style: textTheme.labelLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 28,
                  height: 28,
                  child: IconButton.outlined(
                    padding: EdgeInsets.zero,
                    onPressed: onToggleStarfield,
                    icon: Icon(
                      starfieldEnabled
                          ? Icons.auto_awesome
                          : Icons.auto_awesome_outlined,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              section.subtitle,
              style: textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  StatusPill(
                    label: 'Control',
                    icon: Icons.rocket_launch_outlined,
                    compact: true,
                  ),
                  StatusPill(
                    label: starfieldEnabled ? 'Online' : 'Muted',
                    icon: Icons.stars,
                    color: starfieldEnabled
                        ? SpaceMissionTheme.highlight
                        : SpaceMissionTheme.textMuted,
                    compact: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return MissionPanel(
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CurrentBrandMark(height: 32),
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
                const SizedBox(height: 10),
                Text(section.subtitle, style: textTheme.bodyMedium),
                const SizedBox(height: 10),
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
                const SizedBox(height: 10),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            MissionSection.values.length,
            (index) {
              final item = MissionSection.values[index];
              final isSelected = selectedSection.index == index;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Tooltip(
                  message: item.title,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => onSelect(item),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SpaceMissionTheme.accent.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? SpaceMissionTheme.accent
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: 22,
                              color:
                                  isSelected ? SpaceMissionTheme.accent : null,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: isSelected
                                        ? SpaceMissionTheme.accent
                                        : null,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            MissionSection.values.length,
            (index) {
              final item = MissionSection.values[index];
              final isSelected = section.index == index;
              return Tooltip(
                message: item.title,
                child: IconButton(
                  onPressed: () => onSelect(index),
                  icon: Icon(item.icon),
                  isSelected: isSelected,
                  selectedIcon:
                      Icon(item.icon, color: SpaceMissionTheme.accent),
                  iconSize: 24,
                  padding: const EdgeInsets.all(8),
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                ),
              );
            },
          ),
        ),
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

class _MobileFooterAttribution extends StatelessWidget {
  const _MobileFooterAttribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SpaceMissionTheme.border.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Built with ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SpaceMissionTheme.textMuted,
                ),
          ),
          Icon(
            Icons.favorite,
            size: 12,
            color: SpaceMissionTheme.warning,
          ),
          Text(
            ' by Third Version Technology Ltd.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SpaceMissionTheme.textMuted,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
