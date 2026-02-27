import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:popover_pro/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Popover Flow Integration Tests', () {
    testWidgets('Nested Popover Flow - Dropdown triggers Modal',
        (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const PopoverProApp());
      await tester.pumpAndSettle();

      // Verify app loaded
      expect(find.text('PopoverPro Demo'), findsOneWidget);

      // Scroll to find the nested popovers section
      await tester.scrollUntilVisible(
        find.byKey(const Key('nested-dropdown-trigger')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Step 1: Open the primary dropdown popover
      await tester.tap(find.byKey(const Key('nested-dropdown-trigger')));
      await tester.pumpAndSettle();

      // Verify dropdown is shown
      expect(find.byKey(const Key('dropdown-popover')), findsOneWidget);

      // Step 2: Tap on "Delete Item" to trigger nested modal
      await tester.tap(find.text('Delete Item'));
      await tester.pumpAndSettle();

      // Verify modal is displayed (the nested modal)
      expect(find.byKey(const Key('nested-modal')), findsOneWidget);

      // Verify both popovers are correctly managed - dropdown should be dismissed
      // and modal should be visible with its content
      expect(find.text('Confirm Deletion'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this item? This action cannot be undone.'), findsOneWidget);

      // Step 3: Verify modal has cancel and confirm buttons
      expect(find.byKey(const Key('nested-modal-cancel')), findsOneWidget);
      expect(find.byKey(const Key('nested-modal-confirm')), findsOneWidget);

      // Step 4: Dismiss the modal by tapping Cancel
      await tester.tap(find.byKey(const Key('nested-modal-cancel')));
      await tester.pumpAndSettle();

      // Verify modal is dismissed
      expect(find.byKey(const Key('nested-modal')), findsNothing);

      // Verify we're back to the main UI
      expect(find.text('PopoverPro Demo'), findsOneWidget);
    });

    testWidgets('Tooltip Popover Display and Dismiss',
        (WidgetTester tester) async {
      await tester.pumpWidget(const PopoverProApp());
      await tester.pumpAndSettle();

      // Find and tap a tooltip trigger
      await tester.tap(find.byKey(const Key('tooltip-trigger-up')));
      await tester.pumpAndSettle();

      // Verify tooltip is shown
      expect(find.byKey(const Key('tooltip-popover')), findsOneWidget);

      // Dismiss by tapping outside
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Verify tooltip is dismissed
      expect(find.byKey(const Key('tooltip-popover')), findsNothing);
    });

    testWidgets('Dropdown Popover with Item Selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(const PopoverProApp());
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(find.byKey(const Key('dropdown-trigger')));
      await tester.pumpAndSettle();

      // Verify dropdown is shown
      expect(find.byKey(const Key('dropdown-popover')), findsOneWidget);

      // Select an option
      await tester.tap(find.text('Option 1'));
      await tester.pumpAndSettle();

      // Verify dropdown is dismissed after selection
      expect(find.byKey(const Key('dropdown-popover')), findsNothing);

      // Verify snackbar shows confirmation
      expect(find.text('Selected Option 1'), findsOneWidget);
    });

    testWidgets('Context Menu Popover on Long Press',
        (WidgetTester tester) async {
      await tester.pumpWidget(const PopoverProApp());
      await tester.pumpAndSettle();

      // Scroll to find the context menu area
      await tester.scrollUntilVisible(
        find.byKey(const Key('context-menu-area')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Long press to show context menu
      await tester.longPress(find.byKey(const Key('context-menu-area')));
      await tester.pumpAndSettle();

      // Verify context menu is shown
      expect(find.byKey(const Key('context-menu-popover')), findsOneWidget);

      // Verify menu items
      expect(find.text('Cut'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Paste'), findsOneWidget);

      // Select an item
      await tester.tap(find.text('Copy'));
      await tester.pumpAndSettle();

      // Verify context menu is dismissed
      expect(find.byKey(const Key('context-menu-popover')), findsNothing);

      // Verify snackbar shows confirmation
      expect(find.text('Copy'), findsWidgets);
    });

    testWidgets('Modal Popover with Actions',
        (WidgetTester tester) async {
      await tester.pumpWidget(const PopoverProApp());
      await tester.pumpAndSettle();

      // Scroll to find modal trigger
      await tester.scrollUntilVisible(
        find.byKey(const Key('modal-trigger')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Open modal
      await tester.tap(find.byKey(const Key('modal-trigger')));
      await tester.pumpAndSettle();

      // Verify modal is shown
      expect(find.byKey(const Key('modal-popover')), findsOneWidget);

      // Verify close button exists
      expect(find.byKey(const Key('modal-close-button')), findsOneWidget);

      // Close modal
      await tester.tap(find.byKey(const Key('modal-close-button')));
      await tester.pumpAndSettle();

      // Verify modal is dismissed
      expect(find.byKey(const Key('modal-popover')), findsNothing);
    });

    testWidgets('Scrollable Dropdown with Many Items',
        (WidgetTester tester) async {
      await tester.pumpWidget(const PopoverProApp());
      await tester.pumpAndSettle();

      // Open scrollable dropdown
      await tester.tap(find.byKey(const Key('scrollable-dropdown-trigger')));
      await tester.pumpAndSettle();

      // Verify dropdown is shown
      expect(find.byKey(const Key('dropdown-popover')), findsOneWidget);

      // Verify first items are visible
      expect(find.text('Scrollable Item 1'), findsOneWidget);
      expect(find.text('Scrollable Item 2'), findsOneWidget);

      // Dismiss dropdown
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dropdown-popover')), findsNothing);
    });

    testWidgets('Multiple Popovers - Only One Active at a Time',
        (WidgetTester tester) async {
      await tester.pumpWidget(const PopoverProApp());
      await tester.pumpAndSettle();

      // Open first tooltip
      await tester.tap(find.byKey(const Key('tooltip-trigger-up')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tooltip-popover')), findsOneWidget);

      // Dismiss first tooltip
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tooltip-popover')), findsNothing);

      // Open dropdown
      await tester.tap(find.byKey(const Key('dropdown-trigger')));
      await tester.pumpAndSettle();

      // Only dropdown should be visible
      expect(find.byKey(const Key('dropdown-popover')), findsOneWidget);

      // Dismiss dropdown
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dropdown-popover')), findsNothing);
    });

    testWidgets('Complete User Flow - Browse and Interact',
        (WidgetTester tester) async {
      await tester.pumpWidget(const PopoverProApp());
      await tester.pumpAndSettle();

      // Verify main UI elements
      expect(find.text('PopoverPro Demo'), findsOneWidget);
      expect(find.text('Tooltip Popovers'), findsOneWidget);
      expect(find.text('Dropdown Popovers'), findsOneWidget);

      // Interact with tooltip
      await tester.tap(find.byKey(const Key('tooltip-trigger-up')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tooltip-popover')), findsOneWidget);
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Interact with dropdown
      await tester.tap(find.byKey(const Key('dropdown-trigger')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dropdown-popover')), findsOneWidget);
      await tester.tap(find.text('Option 2'));
      await tester.pumpAndSettle();
      expect(find.text('Selected Option 2'), findsOneWidget);

      // Scroll down to find more sections
      await tester.scrollUntilVisible(
        find.text('Modal Popovers'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Interact with modal
      await tester.tap(find.byKey(const Key('modal-trigger')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('modal-popover')), findsOneWidget);
      await tester.tap(find.byKey(const Key('modal-close-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('modal-popover')), findsNothing);
    });
  });
}
