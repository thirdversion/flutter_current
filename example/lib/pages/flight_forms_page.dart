import 'package:current/current.dart';
import 'package:current_counter_example/space_mission_theme.dart';
import 'package:flutter/material.dart';

import '../components/mission_control_theme.dart';
import '../view_models/flight_forms_validation.dart';
import '../view_models/flight_forms_view_model.dart';

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

  final _formKey = GlobalKey<FormState>();
  final missionCodeController = CurrentTextController.string();
  final crewCountController = CurrentTextController.integer();
  final launchDateController = CurrentTextController.date();

  @override
  void bindCurrentControllers() {
    missionCodeController.bindString(
      property: viewModel.missionCode,
      lifecycleProvider: this,
      validationBuilder: (property, _) => property.createValidation(
        rules: missionCodeRules(),
        validateOnPropertyChange: true,
      ),
    );
    crewCountController.bindInt(
      property: viewModel.crewCapacity,
      lifecycleProvider: this,
      validationBuilder: (property, _) => property.createValidation(
        rules: crewCapacityRules(),
        validateOnPropertyChange: true,
      ),
      validationIssues: const CurrentTextControllerValidationIssues(
        requiredValueIssueBuilder: _crewCapacityRequiredIssue,
        invalidValueIssueBuilder: _crewCapacityInvalidIssue,
      ),
    );
    launchDateController.bindDateTime(
      property: viewModel.launchWindow,
      lifecycleProvider: this,
      fromString: _parseDate,
      asString: (value) => value == null ? '' : _formatDate(value),
      validationBuilder: (property, _) => property.createValidation(
        rules: launchWindowRules(),
        validateOnPropertyChange: true,
      ),
      validationIssues: const CurrentTextControllerValidationIssues(
        requiredValueIssueBuilder: _launchWindowRequiredIssue,
        invalidValueIssueBuilder: _launchWindowInvalidIssue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 1120;
    final group = viewModel.validationGroup;
    final readyForLaunch = group.isValid && !group.hasIssues;
    final firstIssueText = group.resolveFirstIssueText(
      resolver: _resolveValidationText,
    );
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
                      label: 'First issue: ${firstIssueText ?? 'None'}',
                      icon: Icons.rule_outlined,
                      color: group.hasIssues
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Launch authorization input',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'This panel intentionally shows both field integration styles: the wrapper widget and a plain TextFormField using controller.formValidator(...).',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: SpaceMissionTheme.textMuted,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'CurrentTextFormField wrapper',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            CurrentTextFormField<String>(
              controller: missionCodeController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validationTextResolver: _resolveValidationText,
              decoration: const InputDecoration(
                labelText: 'Mission code',
                helperText: 'Try a value like ARTEMIS-2',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Native TextFormField + CurrentTextController',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: crewCountController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: crewCountController.formValidator(
                context: context,
                resolver: _resolveValidationText,
              ),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Crew capacity',
                helperText: 'Digits only. Validation requires 2-8 crew.',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'CurrentTextFormField wrapper',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            CurrentTextFormField<DateTime>(
              controller: launchDateController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validationTextResolver: _resolveValidationText,
              decoration: const InputDecoration(
                labelText: 'Launch window',
                helperText: 'YYYY-MM-DD',
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    final formIsValid =
                        _formKey.currentState?.validate() ?? true;

                    if (!formIsValid) {
                      viewModel.submissionStatus.value =
                          'Launch package still has open validation issues.';
                    }

                    final approved = formIsValid && viewModel.authorizeLaunch();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          approved
                              ? 'Launch package approved. CurrentValidationGroup is clear.'
                              : _firstVisibleFormError(context) ??
                                  viewModel.validationGroup
                                      .resolveFirstIssueText(
                                    resolver: _resolveValidationText,
                                  ) ??
                                  viewModel.submissionStatus.value,
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
                  onPressed: () {
                    _formKey.currentState?.reset();
                    viewModel.resetMissionPlan();
                  },
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
            validation: viewModel.missionCode.validation,
          ),
          const SizedBox(height: 12),
          _ValidationTile(
            title: 'Crew capacity',
            validation: viewModel.crewCapacity.validation,
          ),
          const SizedBox(height: 12),
          _ValidationTile(
            title: 'Launch window',
            validation: viewModel.launchWindow.validation,
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
                label: group.hasIssues ? 'Issues present' : 'No active issues',
                icon: group.hasIssues
                    ? Icons.report_problem_outlined
                    : Icons.checklist_rtl_outlined,
                color: group.hasIssues
                    ? SpaceMissionTheme.danger
                    : SpaceMissionTheme.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _firstVisibleFormError(BuildContext context) {
    return missionCodeController.visibleErrorText(
          context: context,
          resolver: _resolveValidationText,
        ) ??
        crewCountController.visibleErrorText(
          context: context,
          resolver: _resolveValidationText,
        ) ??
        launchDateController.visibleErrorText(
          context: context,
          resolver: _resolveValidationText,
        );
  }

  // Basic example of a validation text resolver that could be used to map issue codes to user-friendly messages or localized strings.
  static String? _resolveValidationText(CurrentValidationIssue issue) {
    switch (issue.code) {
      case 'flightForms.missionCode.required':
        return 'Mission code is required.';
      case 'flightForms.missionCode.format':
        return 'Use a code like ARTEMIS-2.';
      case 'flightForms.missionCode.length':
        return 'Mission code must be at least ${issue.arguments['minimumLength']} characters.';
      case 'flightForms.crewCapacity.minimum':
        return 'Crew capacity must be at least ${issue.arguments['minimumCrew']}.';
      case 'flightForms.crewCapacity.maximum':
        return 'Crew capacity must be ${issue.arguments['maximumCrew']} or fewer.';
      case 'flightForms.crewCapacity.required':
        return 'Crew count is required.';
      case 'flightForms.crewCapacity.invalidFormat':
        return 'Digits only for crew count.';
      case 'flightForms.launchWindow.minimumLeadTime':
        return 'Launch window must be at least ${issue.arguments['minimumHours']} hours from now.';
      case 'flightForms.launchWindow.required':
        return 'Launch window is required.';
      case 'flightForms.launchWindow.invalidFormat':
        return 'Use YYYY-MM-DD.';
    }

    return issue.fallbackMessage ?? issue.code;
  }

  static CurrentValidationIssue _crewCapacityRequiredIssue() {
    return const CurrentValidationIssue('flightForms.crewCapacity.required');
  }

  static CurrentValidationIssue _crewCapacityInvalidIssue(String text) {
    return CurrentValidationIssue(
      'flightForms.crewCapacity.invalidFormat',
      arguments: {'text': text},
    );
  }

  static CurrentValidationIssue _launchWindowRequiredIssue() {
    return const CurrentValidationIssue('flightForms.launchWindow.required');
  }

  static CurrentValidationIssue _launchWindowInvalidIssue(String text) {
    return CurrentValidationIssue(
      'flightForms.launchWindow.invalidFormat',
      arguments: {'text': text},
    );
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
    final color = validation.hasIssue
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
            validation.resolveIssueText(
                  resolver: _FlightFormsPageState._resolveValidationText,
                ) ??
                'No active issue.',
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
