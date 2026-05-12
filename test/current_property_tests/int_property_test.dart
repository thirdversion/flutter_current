import 'package:current/current.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class IntViewModel extends CurrentViewModel {
  final age = CurrentIntProperty(10);

  @override
  Iterable<CurrentProperty> get currentProps => [age];
}

class IntTestWidget extends CurrentWidget<IntViewModel> {
  const IntTestWidget({
    super.key,
    required super.viewModel,
  });

  @override
  CurrentState<CurrentWidget<CurrentViewModel>, IntViewModel> createCurrent() {
    return _IntTestWidgetState(viewModel);
  }
}

class _IntTestWidgetState extends CurrentState<IntTestWidget, IntViewModel> {
  _IntTestWidgetState(super.viewModel);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Center(
              child: Column(
                children: [
                  Text('${viewModel.age}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class NullableIntViewModel extends CurrentViewModel {
  final age = CurrentNullableIntProperty(value: 10);

  @override
  Iterable<CurrentProperty> get currentProps => [age];
}

void main() {
  group('CurrentIntProperty Tests', () {
    late IntViewModel viewModel;
    late IntTestWidget testWidget;

    setUp(() {
      viewModel = IntViewModel();
      testWidget = IntTestWidget(viewModel: viewModel);
    });

    testWidgets('int value changes - widget updates', (tester) async {
      const int expectedValue = 20;

      await tester.pumpWidget(testWidget);

      expect(find.text(viewModel.age.toString()), findsOneWidget);

      viewModel.age(expectedValue);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
    });

    testWidgets('addition - widget updates', (tester) async {
      const int expectedValue = 15;
      const int startingValue = 10;
      const int addend = 5;

      viewModel.age(startingValue);

      await tester.pumpWidget(testWidget);

      expect(find.text(viewModel.age.toString()), findsOneWidget);

      // ignore: deprecated_member_use
      final result = viewModel.age.add(addend);

      viewModel.age(result);
      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, equals(expectedValue));
    });

    testWidgets('subtraction (func) - widget updates', (tester) async {
      const int expectedValue = 5;
      const int startingValue = 10;
      const int subtrahend = 5;

      viewModel.age(startingValue);

      await tester.pumpWidget(testWidget);

      expect(find.text(viewModel.age.toString()), findsOneWidget);

      // ignore: deprecated_member_use
      final result = viewModel.age.subtract(subtrahend);

      viewModel.age(result);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, equals(expectedValue));
    });

    testWidgets('multiplication - widget updates', (tester) async {
      const int expectedValue = 50;
      const int startingValue = 10;
      const int multiplier = 5;

      viewModel.age(startingValue);

      await tester.pumpWidget(testWidget);

      expect(find.text(viewModel.age.toString()), findsOneWidget);

      // ignore: deprecated_member_use
      final result = viewModel.age.multiply(multiplier);

      viewModel.age(result);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, equals(expectedValue));
    });

    testWidgets('division - widget updates', (tester) async {
      const int expectedValue = 2;
      const int startingValue = 10;
      const int divisor = 5;

      viewModel.age(startingValue);

      await tester.pumpWidget(testWidget);

      expect(find.text(viewModel.age.toString()), findsOneWidget);

      final result = viewModel.age.divide(divisor);

      viewModel.age(result.toInt());

      await tester.pumpAndSettle();

      expect(find.text(expectedValue.toString()), findsOneWidget);
      expect(result, equals(expectedValue));
    });
  });
}
