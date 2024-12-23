import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:leak_guard/main.dart';
import 'package:leak_guard/utils/strings.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text(MyStrings.appName), findsOneWidget);
    expect(find.text("Lorem ipsum"), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
