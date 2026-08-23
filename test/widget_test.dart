// Smoke test: the app boots on the Welcome screen and its primary CTA advances
// to phone capture.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chompy/main.dart';
import 'package:chompy/strings.dart';

void main() {
  // Restore-on-launch reads secure storage; provide an empty mock so cold
  // start resolves to the welcome screen.
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (call) async => null,
    );
  });

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
