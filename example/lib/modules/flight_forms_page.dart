import 'package:current/current.dart';
import 'package:flutter/material.dart';

import '../mission_control_theme.dart';

class FlightFormsPage extends CurrentWidget<FlightFormsViewModel> {
  const FlightFormsPage({super.key, required super.viewModel});

  @override
  CurrentState<FlightFormsPage, FlightFormsViewModel> createCurrent() {
    return _FlightFormsPageState(viewModel);
  }
}

class _FlightFormsPageState
    extends CurrentState<FlightFormsPage, FlightFormsViewModel>
    with CurrentTextControllersLifecycleMixin {
  _FlightFormsPageState(super.viewModel);

  final missionCodeController = CurrentTextController.string();
  final crewCountController = CurrentTextController.integer();
  final launchDateController = CurrentTextController.date();

  @override
  void bindCurrentControllers() {
    missionCodeController.bindString(
      property: viewModel.missionCode,
      lifecycleProvider: this,
      validation: viewModel.missionCodeValidation,
    );
    crewCountController.bindInt(
      property: viewModel.crewCapacity,
      lifecycleProvider: this,
      validation: viewModel.crewCapacityValidation,
      validationMessages: CurrentTextControllerValidationMessages(
        requiredValueErrorBuilder: () => 'Crew count is required.',
        invalidValueErrorBuilder: (_) => 'Digits only for crew count.',
      ),
    );
    launchDateController.bindDateTime(
      property: viewModel.launchWindow,
      lifecycleProvider: this,
      fromString: _parseDate,
      asString: (value) => value == null ? '' : _formatDate(value),
      validation: viewModel.launchWindowValidation,
      validationMessages: CurrentTextControllerValidationMessages(
        requiredValueErrorBuilder: () => 'Launch window is required.',
        invalidValueErrorBuilder: (_) => 'Use YYYY-MM-DD.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 1120;
    final group = viewModel.validationGroup;
    final readyForLaunch = group.isValid && !group.hasErrors;
    final panels = [
      _buildFormPanel(context, readyForLaunch),
      _buildStatePanel(context, group),
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
                Text('Flight Forms',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 10),
                Text(
                  'This launch authorization flow is the hero Current 3.0.0 demo: CurrentTextController keeps text fields synchronized with CurrentProperty values, while CurrentValidation tracks touched state, parse failures, and aggregate launch readiness.',
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
                      label: readyForLaunch
                          ? 'Launch-ready'
                          : 'Awaiting validation',
                      icon: readyForLaunch
                          ? Icons.check_circle_outline
                          : Icons.pending_actions_outlined,
                      color: readyForLaunch
                          ? SpaceMissionTheme.highlight
                          : SpaceMissionTheme.warning,
                    ),
                    StatusPill(
                      label: 'First error: ${group.firstErrorText ?? 'None'}',
                      icon: Icons.rule_outlined,
                      color: group.hasErrors
                          ? SpaceMissionTheme.danger
                          : SpaceMissionTheme.accent,
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
                    panels[0],
                    const SizedBox(height: 18),
                    panels[1],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: panels[0]),
                    const SizedBox(width: 18),
                    Expanded(child: panels[1]),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildFormPanel(BuildContext context, bool readyForLaunch) {
    return MissionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Launch authorization input',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: missionCodeController,
            decoration: InputDecoration(
              labelText: 'Mission code',
              helperText: 'Try a value like ORION-7',
              errorText: _visibleError(viewModel.missionCodeValidation),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: crewCountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Crew capacity',
              helperText: 'Digits only. Validation requires 2-8 crew.',
              errorText: _visibleError(viewModel.crewCapacityValidation),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: launchDateController,
            decoration: InputDecoration(
              labelText: 'Launch window',
              helperText: 'YYYY-MM-DD',
              errorText: _visibleError(viewModel.launchWindowValidation),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: () {
                  final approved = viewModel.authorizeLaunch();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        approved
                            ? 'Launch package approved. CurrentValidationGroup is clear.'
                            : viewModel.submissionStatus.value,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text('Authorize launch'),
              ),
              FilledButton.tonalIcon(
                onPressed: viewModel.loadSampleManifest,
                icon: const Icon(Icons.playlist_add_check_circle_outlined),
                label: const Text('Load sample manifest'),
              ),
              OutlinedButton.icon(
                onPressed: viewModel.resetMissionPlan,
                icon: const Icon(Icons.restart_alt_outlined),
                label: const Text('Reset form'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            readyForLaunch
                ? 'All validation rules are satisfied. The launch package can proceed.'
                : 'CurrentValidation metadata blocks submission until each field passes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: readyForLaunch
                      ? SpaceMissionTheme.highlight
                      : SpaceMissionTheme.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatePanel(BuildContext context, CurrentValidationGroup group) {
    final textTheme = Theme.of(context).textTheme;

    return MissionPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Live Current state', style: textTheme.titleLarge),
          const SizedBox(height: 16),
          _ValueLine(
              label: 'missionCode.value',
              value: viewModel.missionCode.value.isEmpty
                  ? '<empty>'
                  : viewModel.missionCode.value),
          _ValueLine(
              label: 'crewCapacity.value',
              value: '${viewModel.crewCapacity.value}'),
          _ValueLine(
              label: 'launchWindow.value',
              value: _formatDate(viewModel.launchWindow.value)),
          _ValueLine(
              label: 'submissionStatus.value',
              value: viewModel.submissionStatus.value),
          const Divider(height: 32),
          Text('Validation telemetry', style: textTheme.titleMedium),
          const SizedBox(height: 12),
          _ValidationTile(
            title: 'Mission code',
            validation: viewModel.missionCodeValidation,
          ),
          const SizedBox(height: 12),
          _ValidationTile(
            title: 'Crew capacity',
            validation: viewModel.crewCapacityValidation,
          ),
          const SizedBox(height: 12),
          _ValidationTile(
            title: 'Launch window',
            validation: viewModel.launchWindowValidation,
          ),
          const Divider(height: 32),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              StatusPill(
                label: group.isValid ? 'Group valid' : 'Group invalid',
                icon: group.isValid
                    ? Icons.verified_outlined
                    : Icons.warning_amber_outlined,
                color: group.isValid
                    ? SpaceMissionTheme.highlight
                    : SpaceMissionTheme.warning,
              ),
              StatusPill(
                label: group.hasErrors ? 'Errors present' : 'No active errors',
                icon: group.hasErrors
                    ? Icons.report_problem_outlined
                    : Icons.checklist_rtl_outlined,
                color: group.hasErrors
                    ? SpaceMissionTheme.danger
                    : SpaceMissionTheme.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String? _visibleError(CurrentFieldValidation<dynamic> validation) {
    if (validation.hasError &&
        (validation.isTouched || validation.hasValidated)) {
      return validation.errorText;
    }

    return null;
  }

  static DateTime _parseDate(String text) {
    return DateTime.parse(text);
  }

  static String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class FlightFormsViewModel extends CurrentViewModel {
  final missionCode = CurrentProperty.string(
    initialValue: '',
    propertyName: 'missionCode',
  );
  final crewCapacity = CurrentProperty.integer(
    initialValue: 0,
    propertyName: 'crewCapacity',
  );
  final launchWindow = CurrentProperty.dateTime(
    initialValue: DateTime.now().add(const Duration(days: 14)),
    propertyName: 'launchWindow',
  );
  final submissionStatus = CurrentProperty.string(
    initialValue: 'Awaiting launch authorization.',
    propertyName: 'submissionStatus',
  );

  late final CurrentFieldValidation<String> missionCodeValidation =
      missionCode.createValidation(
    rules: [
      (value) => value.trim().isEmpty ? 'Mission code is required.' : null,
      (value) => value.contains('-') ? null : 'Use a code like ORION-7.',
      (value) => value.length >= 6
          ? null
          : 'Mission code must be at least 6 characters.',
    ],
    validateOnPropertyChange: true,
  );

  late final CurrentFieldValidation<int> crewCapacityValidation =
      crewCapacity.createValidation(
    rules: [
      (value) => value >= 2 ? null : 'Crew capacity must be at least 2.',
      (value) => value <= 8 ? null : 'Crew capacity must be 8 or fewer.',
    ],
    validateOnPropertyChange: true,
  );

  late final CurrentFieldValidation<DateTime> launchWindowValidation =
      launchWindow.createValidation(
    rules: [
      (value) => value.isAfter(DateTime.now().add(const Duration(days: 2)))
          ? null
          : 'Launch window must be at least 48 hours from now.',
    ],
    validateOnPropertyChange: true,
  );

  late final validationGroup = CurrentValidationGroup([
    missionCodeValidation,
    crewCapacityValidation,
    launchWindowValidation,
  ]);

  @override
  Iterable<CurrentProperty> get currentProps => [
        missionCode,
        crewCapacity,
        launchWindow,
        submissionStatus,
      ];

  @override
  Iterable<CurrentViewModelBinding> get currentBindings => [
        missionCodeValidation,
        crewCapacityValidation,
        launchWindowValidation,
      ];

  bool authorizeLaunch() {
    final isReady = validationGroup.validateAll();

    submissionStatus.value = isReady
        ? 'Launch package approved for ignition.'
        : validationGroup.firstErrorText ??
            'Launch package still has open validation issues.';

    return isReady;
  }

  void loadSampleManifest() {
    setMultiple([
      {missionCode: 'ORION-7'},
      {crewCapacity: 6},
      {launchWindow: DateTime.now().add(const Duration(days: 27))},
    ]);
    submissionStatus.value = 'Sample manifest loaded from mission control.';
  }

  void resetMissionPlan() {
    resetAll();
    validationGroup.resetAll();
  }
}

class _ValueLine extends StatelessWidget {
  const _ValueLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SpaceMissionTheme.textMuted,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

class _ValidationTile extends StatelessWidget {
  const _ValidationTile({
    required this.title,
    required this.validation,
  });

  final String title;
  final CurrentFieldValidation<dynamic> validation;

  @override
  Widget build(BuildContext context) {
    final color = validation.hasError
        ? SpaceMissionTheme.danger
        : validation.hasValidated
            ? SpaceMissionTheme.highlight
            : SpaceMissionTheme.accent;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              StatusPill(
                label: validation.isTouched ? 'Touched' : 'Untouched',
                icon: Icons.touch_app_outlined,
                color: color,
              ),
              StatusPill(
                label: validation.hasValidated
                    ? 'Validated'
                    : 'Awaiting validation',
                icon: Icons.rule_outlined,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            validation.errorText ?? 'No active error.',
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
