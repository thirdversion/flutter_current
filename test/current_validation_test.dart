import 'package:current/current.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _nameRequiredIssue = CurrentValidationIssue(
  'validation.name.required',
);

const _nameTooShortIssue = CurrentValidationIssue(
  'validation.name.tooShort',
);

const _firstNameRequiredIssue = CurrentValidationIssue(
  'validation.firstName.required',
);

const _adultRequiredIssue = CurrentValidationIssue(
  'validation.age.adultRequired',
);

final _contextAwareIssue = CurrentValidationIssue(
  'validation.name.contextAware',
  contextTextBuilder: (context, issue) => 'Name is required from context',
);

String? _englishValidationText(CurrentValidationIssue issue) {
  switch (issue.code) {
    case 'validation.name.required':
      return 'Name is required';
    case 'validation.name.tooShort':
      return 'Name is too short';
    case 'validation.firstName.required':
      return 'First name is required';
    case 'validation.age.adultRequired':
      return 'Must be an adult';
    case 'validation.external.invalid':
      return 'Invalid from external source';
  }

  return issue.fallbackMessage ?? issue.code;
}

String? _frenchValidationText(CurrentValidationIssue issue) {
  switch (issue.code) {
    case 'validation.name.required':
      return 'Le nom est obligatoire';
    case 'validation.name.tooShort':
      return 'Le nom est trop court';
    case 'validation.firstName.required':
      return 'Le prenom est obligatoire';
    case 'validation.age.adultRequired':
      return 'Doit etre majeur';
    case 'validation.external.invalid':
      return 'Valeur invalide provenant d\'une source externe';
  }

  return issue.fallbackMessage ?? issue.code;
}

class _ValidationViewModel extends CurrentViewModel {
  final name = CurrentStringProperty('', propertyName: 'name');
  CurrentFieldValidation<String>? _nameValidation;
  CurrentFieldValidation<String> get nameValidation =>
      _nameValidation ??= name.createValidation(
        rules: [
          (value) => value.isEmpty ? _nameRequiredIssue : null,
          (value) => value.length < 3 ? _nameTooShortIssue : null,
        ],
        validateOnPropertyChange: true,
      );

  @override
  Iterable<CurrentProperty> get currentProps => [name];
}

class _EagerValidationViewModel extends CurrentViewModel {
  final name = CurrentStringProperty('', propertyName: 'name');

  late final CurrentFieldValidation<String> nameValidation =
      name.createValidation(
    rules: [(value) => value.isEmpty ? _nameRequiredIssue : null],
    validateOnPropertyChange: true,
  );

  @override
  Iterable<CurrentProperty> get currentProps => [name];
}

class _AttachmentTrackerBinding implements CurrentViewModelBinding {
  bool attached = false;

  @override
  void attachToViewModel() {
    attached = true;
  }
}

class _BindingBaseViewModel extends CurrentViewModel {
  final name = CurrentStringProperty('', propertyName: 'name');
  final trackerBinding = _AttachmentTrackerBinding();

  @override
  Iterable<CurrentProperty> get currentProps => [name];

  @override
  Iterable<CurrentViewModelBinding> get currentBindings => [trackerBinding];
}

class _BindingAndValidationViewModel extends _BindingBaseViewModel {
  late final CurrentFieldValidation<String> nameValidation =
      name.createValidation(
    rules: [(value) => value.isEmpty ? _nameRequiredIssue : null],
    validateOnPropertyChange: true,
  );
}

class _ValidationWidget extends CurrentWidget<_ValidationViewModel> {
  const _ValidationWidget({
    required super.viewModel,
    this.resolver,
  });

  final CurrentValidationIssueTextResolver? resolver;

  @override
  CurrentState<CurrentWidget<CurrentViewModel>, _ValidationViewModel>
      createCurrent() => _ValidationState(viewModel);
}

class _ValidationState
    extends CurrentState<_ValidationWidget, _ValidationViewModel> {
  _ValidationState(super.viewModel);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        viewModel.nameValidation.resolveIssueText(
              context: context,
              resolver: widget.resolver,
            ) ??
            'valid',
        key: const Key('validation-message'),
      ),
    );
  }
}

void main() {
  group('CurrentFieldValidation', () {
    test('validate - failing rule - stores error metadata', () {
      final property = CurrentStringProperty('', propertyName: 'name');
      final validation = property.createValidation(
        rules: [(value) => value.isEmpty ? _nameRequiredIssue : null],
      );

      final state = validation.validate();

      expect(state.hasIssue, isTrue);
      expect(state.issue, equals(_nameRequiredIssue));
      expect(state.hasValidated, isTrue);
      expect(state.isTouched, isFalse);
    });

    test('validate - markTouched - stores touched metadata', () {
      final property = CurrentStringProperty('', propertyName: 'name');
      final validation = property.createValidation(
        rules: [(value) => value.isEmpty ? _nameRequiredIssue : null],
      );

      validation.validate(markTouched: true);

      expect(validation.isTouched, isTrue);
      expect(validation.issue, equals(_nameRequiredIssue));
    });

    test('createValidation - registers validator on the property', () {
      final property = CurrentStringProperty('', propertyName: 'name');
      final validation = property.createValidation(
        rules: [(value) => value.isEmpty ? _nameRequiredIssue : null],
      );

      expect(property.tryGetValidation(), same(validation));
    });

    test('validate - passing value after failure - clears error metadata', () {
      final property = CurrentStringProperty('', propertyName: 'name');
      final validation = property.createValidation(
        rules: [(value) => value.isEmpty ? _nameRequiredIssue : null],
      );

      validation.validate();
      property('Alice', notifyChange: false);
      validation.validate();

      expect(validation.hasIssue, isFalse);
      expect(validation.issue, isNull);
      expect(validation.isValid, isTrue);
    });

    test('markTouched - untouched field - updates only touched state', () {
      final property = CurrentStringProperty('Alice', propertyName: 'name');
      final validation = property.createValidation();

      validation.markTouched();

      expect(validation.isTouched, isTrue);
      expect(validation.hasValidated, isFalse);
      expect(validation.issue, isNull);
    });

    test('reset - validated field - returns to pristine state', () {
      final property = CurrentStringProperty('', propertyName: 'name');
      final validation = property.createValidation(
        rules: [(value) => value.isEmpty ? _nameRequiredIssue : null],
      );

      validation.validate(markTouched: true);
      validation.reset();

      expect(
          validation.state, equals(const CurrentValidationState.untouched()));
    });

    test('setIssue - manual issue - stores validation metadata', () {
      final property = CurrentStringProperty('Alice', propertyName: 'name');
      final validation = property.createValidation();

      validation.setIssue(
        const CurrentValidationIssue('validation.external.invalid'),
        markTouched: true,
      );

      expect(validation.hasIssue, isTrue);
      expect(
        validation.resolveIssueText(resolver: _englishValidationText),
        equals('Invalid from external source'),
      );
      expect(validation.isTouched, isTrue);
      expect(validation.hasValidated, isTrue);
    });

    testWidgets('resolveIssueText - BuildContext-aware issue builder wins',
        (tester) async {
      String? resolvedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolvedText = _contextAwareIssue.resolveText(context: context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolvedText, equals('Name is required from context'));
    });
  });

  group('CurrentValidationGroup', () {
    test('validateAll - mixed valid and invalid fields - aggregates validity',
        () {
      final firstName = CurrentStringProperty('', propertyName: 'firstName');
      final age = CurrentIntProperty(10, propertyName: 'age');
      final firstNameValidation = firstName.createValidation(
        rules: [(value) => value.isEmpty ? _firstNameRequiredIssue : null],
      );
      final ageValidation = age.createValidation(
        rules: [(value) => value < 18 ? _adultRequiredIssue : null],
      );
      final group = CurrentValidationGroup([
        firstNameValidation,
        ageValidation,
      ]);

      final result = group.validateAll();

      expect(result, isFalse);
      expect(group.hasIssues, isTrue);
      expect(group.firstIssue, equals(_firstNameRequiredIssue));
      expect(
        group.resolveFirstIssueText(resolver: _englishValidationText),
        equals('First name is required'),
      );
    });

    test('forProperties - uses property-registered validations', () {
      final firstName = CurrentStringProperty('', propertyName: 'firstName');
      final age = CurrentIntProperty(10, propertyName: 'age');

      firstName.createValidation(
        rules: [(value) => value.isEmpty ? _firstNameRequiredIssue : null],
      );
      age.createValidation(
        rules: [(value) => value < 18 ? _adultRequiredIssue : null],
      );

      final group = CurrentValidationGroup.forProperties([firstName, age]);

      expect(group.validations, hasLength(2));
      expect(group.validateAll(), isFalse);
      expect(group.firstIssue, equals(_firstNameRequiredIssue));
    });

    test('resetAll - validated fields - clears aggregate errors', () {
      final firstName = CurrentStringProperty('', propertyName: 'firstName');
      final firstNameValidation = firstName.createValidation(
        rules: [(value) => value.isEmpty ? _firstNameRequiredIssue : null],
      );
      final group = CurrentValidationGroup([firstNameValidation]);

      group.validateAll();
      group.resetAll();

      expect(group.hasIssues, isFalse);
      expect(firstNameValidation.state,
          equals(const CurrentValidationState.untouched()));
    });
  });

  group('CurrentValidation integration', () {
    late _ValidationViewModel viewModel;

    setUp(() {
      viewModel = _ValidationViewModel();
    });

    test('validate - emits CurrentValidationChanged with property metadata',
        () async {
      CurrentValidationChanged? receivedEvent;

      final subscription =
          viewModel.addStateChangedListener<CurrentValidationChanged>(
        (event) {
          receivedEvent = event;
        },
        propertyName: 'name',
      );

      viewModel.nameValidation.validate(markTouched: true);
      await Future<void>.microtask(() {});

      expect(receivedEvent, isNotNull);
      expect(receivedEvent?.propertyName, equals('name'));
      expect(
          receivedEvent?.sourceHashCode, equals(viewModel.name.sourceHashCode));
      expect(
        receivedEvent?.validationSourceHashCode,
        equals(viewModel.nameValidation.validationSourceHashCode),
      );
      expect(receivedEvent?.nextValue?.issue, equals(_nameRequiredIssue));

      await subscription.cancel();
    });

    test('property-registered validation coexists with generic bindings',
        () async {
      final viewModelWithBinding = _BindingAndValidationViewModel();

      expect(viewModelWithBinding.trackerBinding.attached, isTrue);
      expect(viewModelWithBinding.nameValidation.issue, isNull);

      viewModelWithBinding.nameValidation.validate();
      await Future<void>.microtask(() {});

      expect(
        viewModelWithBinding.nameValidation.issue,
        equals(_nameRequiredIssue),
      );

      viewModelWithBinding.name('Alice');
      await Future<void>.microtask(() {});

      expect(viewModelWithBinding.nameValidation.issue, isNull);
      expect(viewModelWithBinding.nameValidation.isValid, isTrue);
    });

    test(
        'createValidation before property assignment - auto-attaches when the view model is created',
        () async {
      final eagerViewModel = _EagerValidationViewModel();

      eagerViewModel.nameValidation.validate();
      await Future<void>.microtask(() {});
      expect(eagerViewModel.nameValidation.issue, equals(_nameRequiredIssue));

      eagerViewModel.name('Alex');
      await Future<void>.microtask(() {});

      expect(eagerViewModel.nameValidation.issue, isNull);
      expect(eagerViewModel.nameValidation.isValid, isTrue);
    });

    test(
        'validateOnPropertyChange - property update - revalidates automatically',
        () async {
      viewModel.nameValidation.validate();
      await Future<void>.microtask(() {});

      expect(viewModel.nameValidation.issue, equals(_nameRequiredIssue));

      viewModel.name('Alex');
      await Future<void>.microtask(() {});

      expect(viewModel.nameValidation.issue, isNull);
      expect(viewModel.nameValidation.isValid, isTrue);
    });

    testWidgets(
        'validation change - bound CurrentWidget rebuilds automatically and resolves text in the widget layer',
        (tester) async {
      await tester.pumpWidget(
        _ValidationWidget(
          viewModel: viewModel,
          resolver: _englishValidationText,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('validation-message')), findsOneWidget);
      expect(find.text('valid'), findsOneWidget);

      viewModel.nameValidation.validate(markTouched: true);
      await Future<void>.microtask(() {});
      await tester.pump();

      expect(find.text('Name is required'), findsOneWidget);

      viewModel.name('Alice');
      await Future<void>.microtask(() {});
      await tester.pump();

      expect(find.text('valid'), findsOneWidget);
    });

    testWidgets(
        'the same validation issue can render different localized strings without changing the rule definitions',
        (tester) async {
      viewModel.nameValidation.validate(markTouched: true);
      await Future<void>.microtask(() {});

      await tester.pumpWidget(
        _ValidationWidget(
          viewModel: viewModel,
          resolver: _englishValidationText,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Name is required'), findsOneWidget);

      await tester.pumpWidget(
        _ValidationWidget(
          viewModel: viewModel,
          resolver: _frenchValidationText,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Le nom est obligatoire'), findsOneWidget);
    });
  });
}
