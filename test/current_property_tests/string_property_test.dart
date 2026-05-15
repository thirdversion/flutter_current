import 'package:current/current.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class StringViewModel extends CurrentViewModel {
  final name = CurrentStringProperty('Bob');

  @override
  Iterable<CurrentProperty> get currentProps => [name];
}

class StringTestWidget extends CurrentWidget<StringViewModel> {
  const StringTestWidget({
    super.key,
    required super.viewModel,
  });

  @override
  CurrentState<CurrentWidget<CurrentViewModel>, StringViewModel>
      createCurrent() {
    return _StringTestWidgetState(viewModel);
  }
}

class _StringTestWidgetState
    extends CurrentState<StringTestWidget, StringViewModel> {
  _StringTestWidgetState(super.viewModel);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Center(
              child: Column(
                children: [
                  Text('${viewModel.name}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class NullableStringViewModel extends CurrentViewModel {
  final name = CurrentNullableStringProperty();

  @override
  Iterable<CurrentProperty> get currentProps => [name];
}

void main() {
  group('StringProperty Tests', () {
    late StringViewModel viewModel;
    late StringTestWidget testWidget;

    setUp(() {
      viewModel = StringViewModel();
      testWidget = StringTestWidget(viewModel: viewModel);
    });

    testWidgets('string value changes - widget updates', (tester) async {
      const String expectedValue = 'John';

      await tester.pumpWidget(testWidget);

      expect(find.text(viewModel.name.value), findsOneWidget);

      viewModel.name(expectedValue);

      await tester.pumpAndSettle();

      expect(find.text(expectedValue), findsOneWidget);
    });
  });
}
