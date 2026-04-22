import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pulseguard/main.dart';

void main() {
  testWidgets('PulseGuard app renders correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PulseGuardApp());

    // Verify that the app title is displayed.
    expect(find.text('PulseGuard'), findsOneWidget);
  });
}
