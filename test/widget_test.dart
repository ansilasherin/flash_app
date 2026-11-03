// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:adhil/main.dart';

void main() {
  testWidgets('Flash app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FlashPayApp());

    expect(find.text('FLASH OFF'), findsOneWidget);
    expect(find.byIcon(Icons.flash_off), findsOneWidget);
    expect(find.byIcon(Icons.power_settings_new), findsOneWidget);
  });
}
