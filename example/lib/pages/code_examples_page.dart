import 'package:current/current.dart';
import 'package:mission_control_example/application_view_model.dart';
import 'package:mission_control_example/components/mission_control_theme.dart';
import 'package:mission_control_example/components/mission_section.dart';
import 'package:mission_control_example/extensions.dart';
import 'package:mission_control_example/space_mission_theme.dart';
import 'package:flutter/material.dart';

class CodeExamplesPage extends StatelessWidget {
  const CodeExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 500;
    final isTablet = width < 860;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile
          ? 12
          : isTablet
              ? 14
              : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MissionPanel(
                padding: EdgeInsets.all(isMobile ? 12 : 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Code Examples',
                      style: isMobile
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Small, focused snippets covering common Current patterns.',
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
                        children: const [
                          StatusPill(
                            label: 'View model basics',
                            icon: Icons.memory_outlined,
                            compact: true,
                          ),
                          StatusPill(
                            label: 'Forms + validation',
                            icon: Icons.fact_check_outlined,
                            color: SpaceMissionTheme.highlight,
                            compact: true,
                          ),
                          StatusPill(
                            label: 'Events',
                            icon: Icons.route_outlined,
                            color: SpaceMissionTheme.warning,
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Column(
                children: _snippetSections
                    .map(
                      (snippet) => Padding(
                        padding: EdgeInsets.only(bottom: isMobile ? 10 : 12),
                        child: _SnippetCard(
                          snippet: snippet,
                          compact: isMobile,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnippetCard extends StatelessWidget {
  const _SnippetCard({
    required this.snippet,
    this.compact = false,
  });

  final _SnippetSection snippet;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final appViewModel = Current.viewModelOf<ApplicationViewModel>(context);

    return MissionPanel(
      padding: EdgeInsets.all(compact ? 12 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 8 : 10),
                decoration: BoxDecoration(
                  color: snippet.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(compact ? 12 : 16),
                ),
                child: Icon(
                  snippet.icon,
                  size: compact ? 18 : 20,
                  color: snippet.color,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snippet.title,
                      style: compact
                          ? Theme.of(context).textTheme.titleSmall
                          : Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      snippet.subtitle,
                      style: (compact
                              ? Theme.of(context).textTheme.bodySmall
                              : Theme.of(context).textTheme.bodyMedium)
                          ?.copyWith(
                        color: SpaceMissionTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            snippet.explanation,
            style: (compact
                    ? Theme.of(context).textTheme.bodySmall
                    : Theme.of(context).textTheme.bodyMedium)
                ?.copyWith(
              color: SpaceMissionTheme.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          ...snippet.takeaways.map(
            (takeaway) => Padding(
              padding: EdgeInsets.only(bottom: compact ? 6 : 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_outward,
                    size: compact ? 12 : 14,
                    color: snippet.color,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      takeaway,
                      style: compact
                          ? Theme.of(context).textTheme.bodySmall
                          : Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (snippet.liveSection != null) ...[
            const SizedBox(height: 6),
            FilledButton.tonalIcon(
              onPressed: () => appViewModel.selectSection(snippet.liveSection!),
              icon: const Icon(Icons.launch_outlined),
              label: Text('See this live in ${snippet.liveSectionTitle}'),
            ),
          ],
          const SizedBox(height: 14),
          _CodeBlock(code: snippet.code),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: SpaceMissionTheme.border.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectionArea(
          child: Text(
            code,
            softWrap: true,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontFamily: 'monospace',
                  height: 1.6,
                  color: Colors.white,
                ),
          ),
        ),
      ),
    );
  }
}

class _SnippetSection {
  const _SnippetSection({
    required this.title,
    required this.subtitle,
    required this.explanation,
    required this.takeaways,
    required this.code,
    required this.icon,
    required this.color,
    required this.liveSection,
  });

  final String title;
  final String subtitle;
  final String explanation;
  final List<String> takeaways;
  final String code;
  final IconData icon;
  final Color color;
  final MissionSection? liveSection;

  String? get liveSectionTitle => liveSection?.title;
}

const _snippetSections = [
  _SnippetSection(
    title: 'Start with a view model',
    subtitle: 'Declare reactive properties once',
    explanation:
        'A CurrentViewModel is where your state lives. Add every reactive property to currentProps so CurrentWidget can rebuild automatically when values change.',
    takeaways: [
      'Use typed properties so the API stays expressive and safe.',
      'Keep currentProps complete or the UI will not react to a field.',
      'Use focused view models instead of one giant state object.',
    ],
    icon: Icons.memory_outlined,
    color: SpaceMissionTheme.accent,
    liveSection: MissionSection.telemetry,
    code: '''class MissionViewModel extends CurrentViewModel {
  final missionName = CurrentProperty.string(
    initialValue: 'Odyssey Relay',
    propertyName: 'missionName',
  );

  final crewCount = CurrentProperty.integer(
    initialValue: 4,
    propertyName: 'crewCount',
  );

  @override
  Iterable<CurrentProperty> get currentProps => [
        missionName,
        crewCount,
      ];
}''',
  ),
  _SnippetSection(
    title: 'Bind a widget to Current',
    subtitle: 'Use CurrentWidget and CurrentState',
    explanation:
        'CurrentWidget gives your page a view model and CurrentState rebuilds when the view model emits property changes. No manual ChangeNotifier plumbing is required.',
    takeaways: [
      'Pass the view model into the page widget.',
      'Read property values directly in build.',
      'Trigger mutations from the view model methods or property APIs.',
    ],
    icon: Icons.widgets_outlined,
    color: SpaceMissionTheme.highlight,
    liveSection: MissionSection.telemetry,
    code: r'''class MissionPage extends CurrentWidget<MissionViewModel> {
  const MissionPage({super.key, required super.viewModel});

  @override
  CurrentState<MissionPage, MissionViewModel> createCurrent() {
    return _MissionPageState(viewModel);
  }
}

class _MissionPageState extends CurrentState<MissionPage, MissionViewModel> {
  _MissionPageState(super.viewModel);

  @override
  Widget build(BuildContext context) {
    return Text('Crew: ${viewModel.crewCount.value}');
  }
}''',
  ),
  _SnippetSection(
    title: 'Choose a text field bridge',
    subtitle: 'Wrapper, native Form, or no Form',
    explanation:
        'CurrentTextController keeps text editing synchronized with a property. After that, choose the widget path that matches your UI layer: CurrentTextFormField for the shortest Form setup, native TextFormField when your design system already owns the field widget, or CurrentTextField when you want Current-managed validation outside Flutter Form widgets.',
    takeaways: [
      'Use memoized getters instead of late final for validators and validation groups.',
      'Validation rules can live in the widget, the view model, or in a separate plain-Dart helper file.',
      'Create validation once through property.createValidation or validationBuilder, then read it back from the property.',
      'Use CurrentTextFormField when you want the lowest-boilerplate Form integration.',
      'Use TextFormField with controller.formValidator(...) when you already have a custom field wrapper to preserve.',
      'Use CurrentTextField when there is no Form but you still want Current to manage when errors appear.',
      'Use contextTextBuilder on CurrentValidationIssue when your localization API needs BuildContext.',
    ],
    icon: Icons.fact_check_outlined,
    color: SpaceMissionTheme.warning,
    liveSection: MissionSection.flightForms,
    code: '''
@override
void bindCurrentControllers() {
  missionCodeController.bind(
    property: viewModel.missionCode,
    lifecycleProvider: this,
    validationBuilder: (property, context) => property.createValidation(
      rules: missionCodeRules(),
      validateOnPropertyChange: true,
    ),
  );
}

Widget build(BuildContext context) {
  return Column(
    children: [
      CurrentTextFormField<String>(
        controller: missionCodeController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validationTextResolver: _resolveValidationText,
      ),
      TextFormField(
        controller: crewCountController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: crewCountController.formValidator(
          context: context,
          resolver: _resolveValidationText,
        ),
      ),
      CurrentTextField<String>(
        controller: quickSearchController,
        autovalidateMode: AutovalidateMode.onUserInteractionIfError,
        validationTextResolver: _resolveValidationText,
      ),
    ],
  );
}''',
  ),
  _SnippetSection(
    title: 'Work with collections',
    subtitle: 'Use list and map property types directly',
    explanation:
        'CurrentListProperty and CurrentMapProperty exist so collection mutations stay reactive and reset semantics remain correct. Prefer them over wrapping List or Map in a plain CurrentProperty.',
    takeaways: [
      'Mutate collections with add, remove, update, and clear methods.',
      'The UI rebuilds without replacing the whole collection instance.',
      'resetAll returns the collection to its original baseline.',
    ],
    icon: Icons.route_outlined,
    color: SpaceMissionTheme.accentStrong,
    liveSection: MissionSection.starMap,
    code: '''final routePlan = CurrentProperty.list<String>(
  initialValue: ['Mercury', 'Venus', 'Earth'],
  propertyName: 'routePlan',
);

final cargoManifest = CurrentProperty.map<String, String>(
  initialValue: {'Fuel': '92% capacity'},
  propertyName: 'cargoManifest',
);

routePlan.add('Mars');
cargoManifest.add('Shield Array', 'Thermal shielding aligned');''',
  ),
  _SnippetSection(
    title: 'Listen for events and busy states',
    subtitle: 'Current can do more than property updates',
    explanation:
        'Use custom CurrentStateChanged events for domain milestones, doAsync for task tracking, and addBusyStatusChangedListener or addOnErrorEventListener for side effects like snackbars.',
    takeaways: [
      'Use doAsync to toggle busy automatically around async work.',
      'Listen to specific custom events instead of one catch-all stream.',
      'Error events stay separate from normal state changes.',
    ],
    icon: Icons.rocket_launch_outlined,
    color: SpaceMissionTheme.danger,
    liveSection: MissionSection.launchEvents,
    code: r'''Future<void> runDiagnostics() async {
  await doAsync(() async {
    notifyChange(LaunchMilestoneEvent(
      property: countdown,
      label: 'Telemetry lock acquired',
    ));
  }, busyTaskKey: 'diagnostics');
}

viewModel.addBusyStatusChangedListener(
  (event) => debugPrint('Busy: ${event.isBusy}'),
  busyTaskKey: 'diagnostics',
);''',
  ),
];
