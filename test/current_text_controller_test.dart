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

class _TestCustomObject {
  final int id;
  final String label;

  const _TestCustomObject({required this.id, required this.label});

  static _TestCustomObject parse(String text) {
    final parts = text.split(':');

    if (parts.length != 2) {
      throw const FormatException('Expected format: <id>:<label>');
    }

    return _TestCustomObject(id: int.parse(parts[0]), label: parts[1]);
  }

  String serialize() => '$id:$label';

  @override
  bool operator ==(Object other) {
    return other is _TestCustomObject && other.id == id && other.label == label;
  }

  @override
  int get hashCode => Object.hash(id, label);
}

class _AdditionalTypesViewModel extends CurrentViewModel {
  final title = CurrentStringProperty('Alpha', propertyName: 'title');

  final nullableTitle = CurrentNullableStringProperty(
      value: 'Bravo', propertyName: 'nullableTitle');

  final eventDate = CurrentDateTimeProperty(
    DateTime.utc(2024, 1, 2, 3, 4, 5),
    propertyName: 'eventDate',
  );

  final nullableEventDate = CurrentNullableDateTimeProperty(
    value: DateTime.utc(2024, 6, 7, 8, 9, 10),
    propertyName: 'nullableEventDate',
  );

  final customObject = CurrentProperty<_TestCustomObject>(
    const _TestCustomObject(id: 1, label: 'One'),
    propertyName: 'customObject',
  );

  @override
  Iterable<CurrentProperty> get currentProps => [
        title,
        nullableTitle,
        eventDate,
        nullableEventDate,
        customObject,
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

class _AdditionalTypesControllerTestWidget
    extends CurrentWidget<_AdditionalTypesViewModel> {
  final CurrentTextController<String> titleController;
  final CurrentTextController<String?> nullableTitleController;
  final CurrentTextController<DateTime> eventDateController;
  final CurrentTextController<DateTime?> nullableEventDateController;
  final CurrentTextController<_TestCustomObject> customObjectController;

  const _AdditionalTypesControllerTestWidget({
    required super.viewModel,
    required this.titleController,
    required this.nullableTitleController,
    required this.eventDateController,
    required this.nullableEventDateController,
    required this.customObjectController,
  });

  @override
  CurrentState<CurrentWidget<CurrentViewModel>, _AdditionalTypesViewModel>
      createCurrent() => _AdditionalTypesControllerTestState(viewModel);
}

class _AdditionalTypesControllerTestState extends CurrentState<
    _AdditionalTypesControllerTestWidget,
    _AdditionalTypesViewModel> with CurrentTextControllersLifecycleMixin {
  _AdditionalTypesControllerTestState(super.viewModel);

  @override
  void bindCurrentControllers() {
    widget.titleController.bindString(
      property: viewModel.title,
      lifecycleProvider: this,
    );

    widget.nullableTitleController.bindString(
      property: viewModel.nullableTitle,
      lifecycleProvider: this,
    );

    widget.eventDateController.bindDateTime(
      property: viewModel.eventDate,
      lifecycleProvider: this,
      fromString: DateTime.parse,
    );

    widget.nullableEventDateController.bindDateTime(
      property: viewModel.nullableEventDate,
      lifecycleProvider: this,
      fromString: DateTime.parse,
    );

    widget.customObjectController.bind(
      property: viewModel.customObject,
      lifecycleProvider: this,
      fromString: _TestCustomObject.parse,
      asString: (propertyValue) => propertyValue?.serialize(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            TextField(
              key: const Key('title-field'),
              controller: widget.titleController,
            ),
            TextField(
              key: const Key('nullable-title-field'),
              controller: widget.nullableTitleController,
            ),
            TextField(
              key: const Key('event-date-field'),
              controller: widget.eventDateController,
            ),
            TextField(
              key: const Key('nullable-event-date-field'),
              controller: widget.nullableEventDateController,
            ),
            TextField(
              key: const Key('custom-object-field'),
              controller: widget.customObjectController,
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

  group('CurrentTextController remaining supported types', () {
    late _AdditionalTypesViewModel viewModel;
    late CurrentTextController<String> titleController;
    late CurrentTextController<String?> nullableTitleController;
    late CurrentTextController<DateTime> eventDateController;
    late CurrentTextController<DateTime?> nullableEventDateController;
    late CurrentTextController<_TestCustomObject> customObjectController;

    setUp(() {
      viewModel = _AdditionalTypesViewModel();
      titleController = CurrentTextController.string();
      nullableTitleController = CurrentTextController.nullableString();
      eventDateController = CurrentTextController.date();
      nullableEventDateController = CurrentTextController.nullableDate();
      customObjectController = CurrentTextController.of<_TestCustomObject>();
    });

    tearDown(() {
      titleController.dispose();
      nullableTitleController.dispose();
      eventDateController.dispose();
      nullableEventDateController.dispose();
      customObjectController.dispose();
    });

    Future<void> pumpHarness(WidgetTester tester) async {
      await tester.pumpWidget(
        _AdditionalTypesControllerTestWidget(
          viewModel: viewModel,
          titleController: titleController,
          nullableTitleController: nullableTitleController,
          eventDateController: eventDateController,
          nullableEventDateController: nullableEventDateController,
          customObjectController: customObjectController,
        ),
      );
    }

    testWidgets('string properties sync in both directions', (tester) async {
      await pumpHarness(tester);

      expect(titleController.text, 'Alpha');

      await tester.enterText(find.byKey(const Key('title-field')), 'Delta');
      await tester.pump();

      expect(viewModel.title.value, 'Delta');
      expect(titleController.text, 'Delta');

      viewModel.title('Echo');
      await tester.pump();

      expect(titleController.text, 'Echo');
    });

    testWidgets('nullable string properties clear when the field is cleared',
        (tester) async {
      await pumpHarness(tester);

      expect(nullableTitleController.text, 'Bravo');

      await tester.enterText(
        find.byKey(const Key('nullable-title-field')),
        '',
      );
      await tester.pump();

      expect(viewModel.nullableTitle.value, isNull);
      expect(nullableTitleController.text, '');
    });

    testWidgets(
        'date properties parse input and update when the property value changes',
        (tester) async {
      await pumpHarness(tester);

      final enteredDate = DateTime.utc(2025, 2, 3, 4, 5, 6);
      final updatedDate = DateTime.utc(2026, 7, 8, 9, 10, 11);

      expect(eventDateController.text,
          viewModel.eventDate.value.toIso8601String());

      await tester.enterText(
        find.byKey(const Key('event-date-field')),
        enteredDate.toIso8601String(),
      );
      await tester.pump();

      expect(viewModel.eventDate.value, enteredDate);

      viewModel.eventDate(updatedDate);
      await tester.pump();

      expect(eventDateController.text, updatedDate.toIso8601String());
    });

    testWidgets('nullable date properties clear when the field is cleared',
        (tester) async {
      await pumpHarness(tester);

      await tester.enterText(
        find.byKey(const Key('nullable-event-date-field')),
        '',
      );
      await tester.pump();

      expect(viewModel.nullableEventDate.value, isNull);
      expect(nullableEventDateController.text, '');
    });

    testWidgets(
        'custom object bindings parse input and update when the property value changes',
        (tester) async {
      await pumpHarness(tester);

      const enteredObject = _TestCustomObject(id: 7, label: 'Skye');
      const updatedObject = _TestCustomObject(id: 8, label: 'Luna');

      expect(customObjectController.text, '1:One');

      await tester.enterText(
        find.byKey(const Key('custom-object-field')),
        enteredObject.serialize(),
      );
      await tester.pump();

      expect(viewModel.customObject.value, enteredObject);
      expect(customObjectController.text, enteredObject.serialize());

      viewModel.customObject(updatedObject);
      await tester.pump();

      expect(customObjectController.text, updatedObject.serialize());
    });
  });
}
