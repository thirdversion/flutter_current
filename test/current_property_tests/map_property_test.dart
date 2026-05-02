import 'package:current/current.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class MapViewModel extends CurrentViewModel {
  final data = CurrentMapProperty<String, String>.empty(propertyName: 'data');

  @override
  Iterable<CurrentProperty> get currentProps => [data];
}

class MapTestWidget extends CurrentWidget<MapViewModel> {
  const MapTestWidget({
    super.key,
    required super.viewModel,
  });

  @override
  CurrentState<CurrentWidget<CurrentViewModel>, MapViewModel> createCurrent() {
    return _MapTestWidgetState(viewModel);
  }
}

class _MapTestWidgetState extends CurrentState<MapTestWidget, MapViewModel> {
  _MapTestWidgetState(super.viewModel);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Center(
              child: Column(
                children: [
                  ...viewModel.data.value.keys.map((e) => Text(e)),
                  ...viewModel.data.value.values.map((e) => Text(e))
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  group('CurrentMapProperty Tests', () {
    late MapViewModel viewModel;
    late MapTestWidget testWidget;
    setUp(() {
      viewModel = MapViewModel();
      testWidget = MapTestWidget(viewModel: viewModel);
    });

    testWidgets('add - widget updates', (tester) async {
      const String expectedKey = 'name';
      const String expectedValue = 'Bob';

      await tester.pumpWidget(testWidget);

      expect(find.text(expectedKey), findsNothing);
      expect(find.text(expectedValue), findsNothing);

      viewModel.data.add(expectedKey, expectedValue);

      await tester.pumpAndSettle();

      expect(find.text(expectedKey), findsOneWidget);
      expect(find.text(expectedValue), findsOneWidget);
    });

    testWidgets('addEntry - widget updates', (tester) async {
      const String expectedKey = 'name';
      const String expectedValue = 'Bob';

      await tester.pumpWidget(testWidget);

      expect(find.text(expectedKey), findsNothing);
      expect(find.text(expectedValue), findsNothing);

      viewModel.data.addEntry(const MapEntry(expectedKey, expectedValue));

      await tester.pumpAndSettle();

      expect(find.text(expectedKey), findsOneWidget);
      expect(find.text(expectedValue), findsOneWidget);
    });

    testWidgets('addEntries - widget updates', (tester) async {
      const String expectedKeyOne = 'firstName';
      const String expectedValueOne = 'Bob';
      const String expectedKeyTwo = 'lastName';
      const String expectedValueTwo = 'Smith';

      await tester.pumpWidget(testWidget);

      expect(find.text(expectedKeyOne), findsNothing);
      expect(find.text(expectedValueOne), findsNothing);
      expect(find.text(expectedKeyTwo), findsNothing);
      expect(find.text(expectedValueTwo), findsNothing);

      viewModel.data.addEntries([
        const MapEntry(expectedKeyOne, expectedValueOne),
        const MapEntry(expectedKeyTwo, expectedValueTwo)
      ]);

      await tester.pumpAndSettle();

      expect(find.text(expectedKeyOne), findsOneWidget);
      expect(find.text(expectedValueOne), findsOneWidget);
      expect(find.text(expectedKeyTwo), findsOneWidget);
      expect(find.text(expectedValueTwo), findsOneWidget);
    });

    testWidgets('addAll - widget updates', (tester) async {
      const String expectedKeyOne = 'firstName';
      const String expectedValueOne = 'Bob';
      const String expectedKeyTwo = 'lastName';
      const String expectedValueTwo = 'Smith';

      await tester.pumpWidget(testWidget);

      expect(find.text(expectedKeyOne), findsNothing);
      expect(find.text(expectedValueOne), findsNothing);
      expect(find.text(expectedKeyTwo), findsNothing);
      expect(find.text(expectedValueTwo), findsNothing);

      viewModel.data.addAll({
        expectedKeyOne: expectedValueOne,
        expectedKeyTwo: expectedValueTwo,
      });

      await tester.pumpAndSettle();

      expect(find.text(expectedKeyOne), findsOneWidget);
      expect(find.text(expectedValueOne), findsOneWidget);
      expect(find.text(expectedKeyTwo), findsOneWidget);
      expect(find.text(expectedValueTwo), findsOneWidget);
    });

    testWidgets('update - key is present - widget updates', (tester) async {
      const String keyOne = 'firstName';
      const String valueOne = 'Bob';
      const String keyTwo = 'lastName';
      const String valueTwo = 'Smith';
      const String expectedUpdatedValue = 'Doe';

      final Map<String, String> data = {
        keyOne: valueOne,
        keyTwo: valueTwo,
      };

      viewModel.data.addAll(data);

      await tester.pumpWidget(testWidget);

      viewModel.data.update(keyOne, (value) => value = expectedUpdatedValue);

      await tester.pumpAndSettle();

      expect(find.text(expectedUpdatedValue), findsOneWidget);
    });

    testWidgets('update - key is not preset - calls ifAbsent - widget updates',
        (tester) async {
      const String keyOne = 'firstName';

      const String expectedUpdatedValue = 'Doe';

      await tester.pumpWidget(testWidget);

      viewModel.data.update(
        keyOne,
        (value) => value = expectedUpdatedValue,
        ifAbsent: () => expectedUpdatedValue,
      );

      await tester.pumpAndSettle();

      expect(find.text(expectedUpdatedValue), findsOneWidget);
    });

    testWidgets('updateAll - updates all values - widget updates',
        (tester) async {
      const String keyOne = 'firstName';
      const String valueOne = 'bob';
      const String keyTwo = 'lastName';
      const String valueTwo = 'smith';
      const String expectedValueOne = 'BOB';
      const String expectedValueTwo = 'SMITH';

      final Map<String, String> data = {
        keyOne: valueOne,
        keyTwo: valueTwo,
      };

      viewModel.data.addAll(data);

      await tester.pumpWidget(testWidget);

      expect(find.text(expectedValueOne), findsNothing);
      expect(find.text(expectedValueTwo), findsNothing);

      viewModel.data.updateAll((key, value) => value.toUpperCase());

      await tester.pumpAndSettle();

      expect(find.text(expectedValueOne), findsOneWidget);
      expect(find.text(expectedValueTwo), findsOneWidget);
    });

    testWidgets('removeWhere - removes matching items - widget updates',
        (tester) async {
      const String keyOne = 'firstName';
      const String valueOne = 'Bob';
      const String keyTwo = 'lastName';
      const String valueTwo = 'Smith';

      final Map<String, String> data = {
        keyOne: valueOne,
        keyTwo: valueTwo,
      };

      viewModel.data.addAll(data);

      await tester.pumpWidget(testWidget);

      expect(find.text(keyOne), findsOneWidget);
      expect(find.text(valueOne), findsOneWidget);
      expect(find.text(keyTwo), findsOneWidget);
      expect(find.text(valueTwo), findsOneWidget);

      viewModel.data.removeWhere((key, value) => key == keyOne);

      await tester.pumpAndSettle();

      expect(find.text(keyOne), findsNothing);
      expect(find.text(valueOne), findsNothing);
      expect(find.text(keyTwo), findsOneWidget);
      expect(find.text(valueTwo), findsOneWidget);
      expect(viewModel.data.length, 1);
    });

    testWidgets('remove - key is present - item removed - widget updates',
        (tester) async {
      const String keyOne = 'firstName';
      const String valueOne = 'Bob';
      const String keyTwo = 'lastName';
      const String valueTwo = 'Smith';

      final Map<String, String> data = {
        keyOne: valueOne,
        keyTwo: valueTwo,
      };

      viewModel.data.addAll(data);

      await tester.pumpWidget(testWidget);

      expect(find.text(keyOne), findsOneWidget);
      expect(find.text(valueOne), findsOneWidget);
      expect(find.text(keyTwo), findsOneWidget);
      expect(find.text(valueTwo), findsOneWidget);

      viewModel.data.remove(keyTwo);

      await tester.pumpAndSettle();

      expect(find.text(keyOne), findsOneWidget);
      expect(find.text(valueOne), findsOneWidget);
      expect(find.text(keyTwo), findsNothing);
      expect(find.text(valueTwo), findsNothing);
    });

    testWidgets(
        'removeWhere - predicate finds match - item removed - widget updates',
        (tester) async {
      const String keyOne = 'firstName';
      const String valueOne = 'Bob';
      const String keyTwo = 'lastName';
      const String valueTwo = 'Smith';

      final Map<String, String> data = {
        keyOne: valueOne,
        keyTwo: valueTwo,
      };

      viewModel.data.addAll(data);

      await tester.pumpWidget(testWidget);

      expect(find.text(keyOne), findsOneWidget);
      expect(find.text(valueOne), findsOneWidget);
      expect(find.text(keyTwo), findsOneWidget);
      expect(find.text(valueTwo), findsOneWidget);

      viewModel.data.removeWhere((key, value) => value == valueTwo);

      await tester.pumpAndSettle();

      expect(find.text(keyOne), findsOneWidget);
      expect(find.text(valueOne), findsOneWidget);
      expect(find.text(keyTwo), findsNothing);
      expect(find.text(valueTwo), findsNothing);
    });

    testWidgets('clear - all items removed - widget updates', (tester) async {
      const String keyOne = 'firstName';
      const String valueOne = 'Bob';
      const String keyTwo = 'lastName';
      const String valueTwo = 'Smith';

      final Map<String, String> data = {
        keyOne: valueOne,
        keyTwo: valueTwo,
      };

      viewModel.data.addAll(data);

      await tester.pumpWidget(testWidget);

      expect(find.text(keyOne), findsOneWidget);
      expect(find.text(valueOne), findsOneWidget);
      expect(find.text(keyTwo), findsOneWidget);
      expect(find.text(valueTwo), findsOneWidget);

      viewModel.data.clear();

      await tester.pumpAndSettle();

      expect(find.text(keyOne), findsNothing);
      expect(find.text(valueOne), findsNothing);
      expect(find.text(keyTwo), findsNothing);
      expect(find.text(valueTwo), findsNothing);
    });

    test('containsKey - has matching key - returns true', () {
      const String key = 'name';
      const String value = 'Bob';

      viewModel.data.add(key, value);

      final result = viewModel.data.containsKey(key);

      expect(result, isTrue);
    });

    test('containsKey - has no matching key - returns false', () {
      const String key = 'name';
      const String value = 'Bob';
      const String missingKey = 'lastName';

      viewModel.data.add(key, value);

      final result = viewModel.data.containsKey(missingKey);

      expect(result, isFalse);
    });

    test('containsValue - has matching value - returns true', () {
      const String key = 'name';
      const String value = 'Bob';

      viewModel.data.add(key, value);

      final result = viewModel.data.containsValue(value);

      expect(result, isTrue);
    });

    test('containsValue - has no matching value - returns false', () {
      const String key = 'name';
      const String value = 'Bob';
      const String missingValue = 'Smith';

      viewModel.data.add(key, value);

      final result = viewModel.data.containsValue(missingValue);

      expect(result, isFalse);
    });

    test('[] operator - has matching key - returns value', () {
      const String key = 'name';
      const String value = 'Bob';

      viewModel.data.add(key, value);

      final result = viewModel.data[key];

      expect(result, equals(value));
    });

    test('[] operator - has no matching key - returns null', () {
      const String key = 'name';
      const String value = 'Bob';
      const String missingKey = 'lastName';

      viewModel.data.add(key, value);

      final result = viewModel.data[missingKey];

      expect(result, isNull);
    });

    test('isDirty - map is unchanged from original value - returns false', () {
      final data = CurrentMapProperty<String, String>({'name': 'Bob'});

      expect(data.isDirty, isFalse);
    });

    test('add - emits event with property metadata', () async {
      CurrentStateChanged? receivedEvent;

      final subscription = viewModel
          .addAnyStateChangedListener((event) => receivedEvent = event);

      viewModel.data.add('name', 'Bob');
      await Future<void>.microtask(() {});

      expect(receivedEvent, isNotNull);
      final nextValue = receivedEvent?.nextValue as MapEntry<String, String>?;
      expect(nextValue?.key, equals('name'));
      expect(nextValue?.value, equals('Bob'));
      expect(receivedEvent?.previousValue, isNull);
      expect(receivedEvent?.propertyName, equals('data'));
      expect(
          receivedEvent?.sourceHashCode, equals(viewModel.data.sourceHashCode));

      await subscription.cancel();
    });

    test('addAll - capturePrevious captures previous map state', () async {
      CurrentStateChanged? receivedEvent;
      final subscription = viewModel.addAnyStateChangedListener((event) => receivedEvent = event);

      viewModel.data.addAll({'name': 'Bob'}, notifyChanges: false);
      viewModel.data.addAll({'planet': 'Earth'}, capturePrevious: true);
      await Future<void>.microtask(() {});

      expect(receivedEvent?.previousValue, equals({'name': 'Bob'}));
      await subscription.cancel();
    });

    test('addEntries - capturePrevious captures previous map state', () async {
      CurrentStateChanged? receivedEvent;
      final subscription = viewModel.addAnyStateChangedListener((event) => receivedEvent = event);

      viewModel.data.addAll({'name': 'Bob'}, notifyChanges: false);
      viewModel.data.addEntries([const MapEntry('planet', 'Earth')], capturePrevious: true);
      await Future<void>.microtask(() {});

      final previousEntries = receivedEvent?.previousValue as Iterable<MapEntry<String, String>>?;
      expect(previousEntries?.first.key, equals('name'));
      expect(previousEntries?.first.value, equals('Bob'));
      await subscription.cancel();
    });

    test('clear - emits a concrete snapshot of previous items', () async {
      CurrentStateChanged? receivedEvent;

      final subscription = viewModel
          .addAnyStateChangedListener((event) => receivedEvent = event);

      viewModel.data
          .addAll({'name': 'Bob', 'planet': 'Earth'}, notifyChanges: false);
      viewModel.data.clear();
      await Future<void>.microtask(() {});

      expect(receivedEvent, isNotNull);
      expect(receivedEvent?.previousValue, isNull);
      expect(receivedEvent?.nextValue, equals(<String, String>{}));
      expect(receivedEvent?.propertyName, equals('data'));

      await subscription.cancel();
    });

    test('clear - capturePrevious captures previous map state', () async {
      CurrentStateChanged? receivedEvent;
      final subscription = viewModel.addAnyStateChangedListener((event) => receivedEvent = event);

      viewModel.data.addAll({'name': 'Bob'}, notifyChanges: false);
      viewModel.data.clear(capturePrevious: true);
      await Future<void>.microtask(() {});

      expect(receivedEvent?.previousValue, equals({'name': 'Bob'}));
      await subscription.cancel();
    });

    test('isDirty - map changes from original value - returns true', () {
      final data = CurrentMapProperty<String, String>({'name': 'Bob'});
      data.setViewModel(viewModel);

      data.add('lastName', 'Smith', notifyChanges: false);

      expect(data.isDirty, isTrue);
    });

    test(
        'reset - starting map is empty - add item - should be empty after reset',
        () {
      final data = CurrentMapProperty<String, String>.empty();
      data.setViewModel(viewModel);
      data.add('name', 'Bob');

      expect(data.isNotEmpty, isTrue);

      data.reset();

      expect(data.isEmpty, isTrue);
    });

    test(
        'reset - starting map has data - add item - only original data after reset',
        () {
      const String key = 'firstName';
      const String value = 'Bob';
      const String tmpKey = 'lastName';
      const String tmpValue = 'Smith';

      final data = CurrentMapProperty<String, String>({key: value});
      data.setViewModel(viewModel);

      expect(data.containsKey(key), isTrue);
      expect(data.containsValue(value), isTrue);

      data.add(tmpKey, tmpValue);

      expect(data.containsKey(tmpKey), isTrue);
      expect(data.containsValue(tmpValue), isTrue);

      data.reset();

      expect(data.containsKey(tmpKey), isFalse);
      expect(data.containsValue(tmpValue), isFalse);
      expect(data.containsKey(key), isTrue);
      expect(data.containsValue(value), isTrue);
    });

    test('resetting retains original value', () {
      final data = CurrentMapProperty<String, String>.empty();
      data.setViewModel(viewModel);
      data.add('name', 'Bob');

      data.reset();

      expect(data.isEmpty, isTrue);

      data.add('name', 'Bob');

      expect(data.originalValue.isEmpty, isTrue);
    });
  });
}
