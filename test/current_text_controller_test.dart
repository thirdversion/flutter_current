import 'package:current/current.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _ControllerTestViewModel extends CurrentViewModel {
  final name = CurrentStringProperty('Alice', propertyName: 'name');
  final age = CurrentIntProperty(10, propertyName: 'age');
  final alternateAge = CurrentIntProperty(20, propertyName: 'alternateAge');
  final nullableAge =
      CurrentNullableIntProperty(value: 7, propertyName: 'nullableAge');

  @override
  Iterable<CurrentProperty> get currentProps => [
        name,
        age,
        alternateAge,
        nullableAge,
      ];
}

class _ControllerTestWidget extends CurrentWidget<_ControllerTestViewModel> {
  final CurrentTextController<String> nameController;
  final CurrentTextController<int> ageController;
  final CurrentTextController<int?> nullableAgeController;
  final bool bindAlternateAge;
  final int? ageDefaultValue;

  const _ControllerTestWidget({
    required super.viewModel,
    required this.nameController,
    required this.ageController,
    required this.nullableAgeController,
    this.bindAlternateAge = false,
    this.ageDefaultValue,
  });

  @override
  CurrentState<CurrentWidget<CurrentViewModel>, _ControllerTestViewModel>
      createCurrent() => _ControllerTestState(viewModel);
}

class _ControllerTestState
    extends CurrentState<_ControllerTestWidget, _ControllerTestViewModel>
    with CurrentTextControllersLifecycleMixin {
  _ControllerTestState(super.viewModel);

  @override
  void bindCurrentControllers() {
    widget.nameController.bindString(
      property: viewModel.name,
      lifecycleProvider: this,
    );

    widget.ageController.bindInt(
      property:
          widget.bindAlternateAge ? viewModel.alternateAge : viewModel.age,
      lifecycleProvider: this,
      defaultValue: widget.ageDefaultValue,
    );

    widget.nullableAgeController.bindInt(
      property: viewModel.nullableAge,
      lifecycleProvider: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            TextField(
              key: const Key('name-field'),
              controller: widget.nameController,
            ),
            TextField(
              key: const Key('age-field'),
              controller: widget.ageController,
            ),
            TextField(
              key: const Key('nullable-age-field'),
              controller: widget.nullableAgeController,
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('CurrentTextController', () {
    late _ControllerTestViewModel viewModel;
    late CurrentTextController<String> nameController;
    late CurrentTextController<int> ageController;
    late CurrentTextController<int?> nullableAgeController;

    setUp(() {
      viewModel = _ControllerTestViewModel();
      nameController = CurrentTextController.string();
      ageController = CurrentTextController.integer();
      nullableAgeController = CurrentTextController.nullableInteger();
    });

    tearDown(() {
      nameController.dispose();
      ageController.dispose();
      nullableAgeController.dispose();
    });

    test('unbound controller works just like a normal TextEditingController',
        () {
      final controller = CurrentTextController.integer();

      controller.text = '123';

      expect(controller.text, '123');

      controller.dispose();
    });

    testWidgets('valid text updates the bound property', (tester) async {
      await tester.pumpWidget(
        _ControllerTestWidget(
          viewModel: viewModel,
          nameController: nameController,
          ageController: ageController,
          nullableAgeController: nullableAgeController,
        ),
      );

      await tester.enterText(find.byKey(const Key('age-field')), '42');
      await tester.pump();

      expect(viewModel.age.value, 42);
      expect(ageController.text, '42');
    });

    testWidgets('external property changes update the bound text',
        (tester) async {
      await tester.pumpWidget(
        _ControllerTestWidget(
          viewModel: viewModel,
          nameController: nameController,
          ageController: ageController,
          nullableAgeController: nullableAgeController,
        ),
      );

      viewModel.age(11);
      await tester.pump();

      expect(ageController.text, '11');
    });

    testWidgets(
        'invalid text stays visible and unrelated property events do not nuke it',
        (tester) async {
      await tester.pumpWidget(
        _ControllerTestWidget(
          viewModel: viewModel,
          nameController: nameController,
          ageController: ageController,
          nullableAgeController: nullableAgeController,
        ),
      );

      await tester.enterText(find.byKey(const Key('age-field')), 'abc');
      await tester.pump();

      expect(viewModel.age.value, 10);
      expect(ageController.text, 'abc');

      viewModel.alternateAge(10);
      await tester.pump();

      expect(viewModel.age.value, 10);
      expect(ageController.text, 'abc');
    });

    testWidgets('empty text applies the explicit default for non-nullable ints',
        (tester) async {
      await tester.pumpWidget(
        _ControllerTestWidget(
          viewModel: viewModel,
          nameController: nameController,
          ageController: ageController,
          nullableAgeController: nullableAgeController,
          ageDefaultValue: 5,
        ),
      );

      await tester.enterText(find.byKey(const Key('age-field')), '');
      await tester.pump();

      expect(viewModel.age.value, 5);
      expect(ageController.text, '5');
    });

    testWidgets(
        'clearing a non-nullable property without a default re-syncs and selects the field',
        (tester) async {
      await tester.pumpWidget(
        _ControllerTestWidget(
          viewModel: viewModel,
          nameController: nameController,
          ageController: ageController,
          nullableAgeController: nullableAgeController,
        ),
      );

      await tester.enterText(find.byKey(const Key('age-field')), '3');
      await tester.pump();

      expect(viewModel.age.value, 3);
      expect(ageController.text, '3');

      await tester.enterText(find.byKey(const Key('age-field')), '');
      await tester.pump();

      expect(viewModel.age.value, 3);
      expect(ageController.text, '3');
      expect(ageController.selection.baseOffset, 0);
      expect(ageController.selection.extentOffset, 1);
    });

    testWidgets('empty text clears nullable integer properties',
        (tester) async {
      await tester.pumpWidget(
        _ControllerTestWidget(
          viewModel: viewModel,
          nameController: nameController,
          ageController: ageController,
          nullableAgeController: nullableAgeController,
        ),
      );

      await tester.enterText(find.byKey(const Key('nullable-age-field')), '');
      await tester.pump();

      expect(viewModel.nullableAge.value, isNull);
      expect(nullableAgeController.text, '');
    });

    testWidgets(
        'controllers rebind when bindCurrentControllers targets a new property',
        (tester) async {
      await tester.pumpWidget(
        _ControllerTestWidget(
          viewModel: viewModel,
          nameController: nameController,
          ageController: ageController,
          nullableAgeController: nullableAgeController,
        ),
      );

      expect(ageController.text, '10');

      await tester.pumpWidget(
        _ControllerTestWidget(
          viewModel: viewModel,
          nameController: nameController,
          ageController: ageController,
          nullableAgeController: nullableAgeController,
          bindAlternateAge: true,
        ),
      );
      await tester.pump();

      expect(ageController.text, '20');

      viewModel.age(99);
      await tester.pump();
      expect(ageController.text, '20');

      viewModel.alternateAge(21);
      await tester.pump();
      expect(ageController.text, '21');
    });
  });
}
