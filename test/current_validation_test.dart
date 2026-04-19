import 'package:current/current.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ValidationViewModel extends CurrentViewModel {
  final name = CurrentStringProperty('', propertyName: 'name');
  late final nameValidation = name.createValidation(
    rules: [
      (value) => value.isEmpty ? 'Name is required' : null,
      (value) => value.length < 3 ? 'Name is too short' : null,
    ],
    validateOnPropertyChange: true,
  );

  @override
  Iterable<CurrentProperty> get currentProps => [name];

  @override
  Iterable<CurrentViewModelBinding> get currentBindings => [nameValidation];
}

class _ValidationWidget extends CurrentWidget<_ValidationViewModel> {
  const _ValidationWidget({required super.viewModel});

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
        viewModel.nameValidation.errorText ?? 'valid',
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
        rules: [(value) => value.isEmpty ? 'Name is required' : null],
      );

      final state = validation.validate();

      expect(state.hasError, isTrue);
      expect(state.errorText, equals('Name is required'));
      expect(state.hasValidated, isTrue);
      expect(state.isTouched, isFalse);
    });

    test('validate - markTouched - stores touched metadata', () {
      final property = CurrentStringProperty('', propertyName: 'name');
      final validation = property.createValidation(
        rules: [(value) => value.isEmpty ? 'Name is required' : null],
      );

      validation.validate(markTouched: true);

      expect(validation.isTouched, isTrue);
      expect(validation.errorText, equals('Name is required'));
    });

    test('validate - passing value after failure - clears error metadata', () {
      final property = CurrentStringProperty('', propertyName: 'name');
      final validation = property.createValidation(
        rules: [(value) => value.isEmpty ? 'Name is required' : null],
      );

      validation.validate();
      property('Alice', notifyChange: false);
      validation.validate();

      expect(validation.hasError, isFalse);
      expect(validation.errorText, isNull);
      expect(validation.isValid, isTrue);
    });

    test('markTouched - untouched field - updates only touched state', () {
      final property = CurrentStringProperty('Alice', propertyName: 'name');
      final validation = property.createValidation();

      validation.markTouched();

      expect(validation.isTouched, isTrue);
      expect(validation.hasValidated, isFalse);
      expect(validation.errorText, isNull);
    });

    test('reset - validated field - returns to pristine state', () {
      final property = CurrentStringProperty('', propertyName: 'name');
      final validation = property.createValidation(
        rules: [(value) => value.isEmpty ? 'Name is required' : null],
      );

      validation.validate(markTouched: true);
      validation.reset();

      expect(
          validation.state, equals(const CurrentValidationState.untouched()));
    });

    test('setError - manual error - stores validation metadata', () {
      final property = CurrentStringProperty('Alice', propertyName: 'name');
      final validation = property.createValidation();

      validation.setError('Invalid from external source', markTouched: true);

      expect(validation.hasError, isTrue);
      expect(validation.errorText, equals('Invalid from external source'));
      expect(validation.isTouched, isTrue);
      expect(validation.hasValidated, isTrue);
    });
  });

  group('CurrentValidationGroup', () {
    test('validateAll - mixed valid and invalid fields - aggregates validity',
        () {
      final firstName = CurrentStringProperty('', propertyName: 'firstName');
      final age = CurrentIntProperty(10, propertyName: 'age');
      final firstNameValidation = firstName.createValidation(
        rules: [(value) => value.isEmpty ? 'First name is required' : null],
      );
      final ageValidation = age.createValidation(
        rules: [(value) => value < 18 ? 'Must be an adult' : null],
      );
      final group = CurrentValidationGroup([
        firstNameValidation,
        ageValidation,
      ]);

      final result = group.validateAll();

      expect(result, isFalse);
      expect(group.hasErrors, isTrue);
      expect(group.firstErrorText, equals('First name is required'));
    });

    test('resetAll - validated fields - clears aggregate errors', () {
      final firstName = CurrentStringProperty('', propertyName: 'firstName');
      final firstNameValidation = firstName.createValidation(
        rules: [(value) => value.isEmpty ? 'First name is required' : null],
      );
      final group = CurrentValidationGroup([firstNameValidation]);

      group.validateAll();
      group.resetAll();

      expect(group.hasErrors, isFalse);
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
      expect(receivedEvent?.nextValue?.errorText, equals('Name is required'));

      await subscription.cancel();
    });

    test(
        'validateOnPropertyChange - property update - revalidates automatically',
        () async {
      viewModel.nameValidation.validate();
      await Future<void>.microtask(() {});

      expect(viewModel.nameValidation.errorText, equals('Name is required'));

      viewModel.name('Alex');
      await Future<void>.microtask(() {});

      expect(viewModel.nameValidation.errorText, isNull);
      expect(viewModel.nameValidation.isValid, isTrue);
    });

    testWidgets(
        'validation change - bound CurrentWidget rebuilds automatically',
        (tester) async {
      await tester.pumpWidget(_ValidationWidget(viewModel: viewModel));
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
  });
}
