// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:popover_pro/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PopoverProApp());

    // Wait for any async operations
    await tester.pumpAndSettle();

    // Verify that the app title is displayed.
    expect(find.text('PopoverPro Demo'), findsOneWidget);

    // Verify main sections are present
    expect(find.text('Tooltip Popovers'), findsOneWidget);
    expect(find.text('Dropdown Popovers'), findsOneWidget);
  });
}
