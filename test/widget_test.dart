// Smoke test: the app boots on the Welcome screen and its primary CTA advances
// to phone capture.

import 'package:flutter_test/flutter_test.dart';

import 'package:chompy/main.dart';
import 'package:chompy/strings.dart';

void main() {
  testWidgets('Welcome shows and Get started moves to phone capture',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ChompyApp());
    await tester.pumpAndSettle();

    // Welcome copy is present.
    expect(find.text(ChompyStrings.welcomeCta), findsOneWidget);

    // Advancing lands on the phone step.
    await tester.tap(find.text(ChompyStrings.welcomeCta));
    await tester.pumpAndSettle();
    expect(find.text(ChompyStrings.phoneTitle), findsOneWidget);
  });
}
