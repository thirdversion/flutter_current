import 'package:current/current.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class BoolViewModel extends CurrentViewModel {
  final isAwesome = CurrentBoolProperty(true);

  @override
  Iterable<CurrentProperty> get currentProps => [isAwesome];
}

class BoolTestWidget extends CurrentWidget<BoolViewModel> {
  const BoolTestWidget({
    super.key,
    required super.viewModel,
  });

  @override
  CurrentState<CurrentWidget<CurrentViewModel>, BoolViewModel> createCurrent() {
    return _BoolTestWidgetState(viewModel);
  }
}

class _BoolTestWidgetState extends CurrentState<BoolTestWidget, BoolViewModel> {
  _BoolTestWidgetState(super.viewModel);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (innerContext) {
            return Center(
              child: Column(
                children: [
                  Text('${viewModel.isAwesome}'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class NullableBoolViewModel extends CurrentViewModel {
  final isAwesome = CurrentNullableBoolProperty();

  @override
  Iterable<CurrentProperty> get currentProps => [isAwesome];
}

void main() {
  group('CurrentBoolProperty Tests', () {
    late BoolViewModel viewModel;
    late BoolTestWidget testWidget;
    setUp(() {
      viewModel = BoolViewModel();
      testWidget = BoolTestWidget(viewModel: viewModel);
    });

    testWidgets('bool value changes - widget updates', (tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text("true"), findsOneWidget);

      viewModel.isAwesome(false);

      await tester.pumpAndSettle();

      expect(find.text("false"), findsOneWidget);
    });
  });
}
