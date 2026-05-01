import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mission_control_example/main.dart';

void main() {
  testWidgets('mission control shell renders and navigates to flight forms',
      (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Mission Overview'), findsWidgets);
    expect(find.text('Orbit every Current feature from one mission deck.'),
        findsOneWidget);

    await tester.tap(find.text('Flight Forms').last);
    await tester.pumpAndSettle();

    expect(find.text('Launch authorization'), findsOneWidget);
    expect(find.text('Authorize launch'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(3));
  });
}
