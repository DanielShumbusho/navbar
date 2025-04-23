import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:navbar/main.dart';

void main() {
  testWidgets('Bottom navigation changes page', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Verify default screen is Sign Up
    expect(find.text('Sign Up Page'), findsOneWidget);

    // Tap on "Sign In" tab
    await tester.tap(find.byIcon(Icons.login));
    await tester.pump();

    // Verify Sign In screen appears
    expect(find.text('Sign In Page'), findsOneWidget);

    // Tap on "Dashboard" tab
    await tester.tap(find.byIcon(Icons.dashboard));
    await tester.pump();

    // Verify Dashboard screen appears
    expect(find.text('Dashboard Page'), findsOneWidget);

    // Tap on "Calculator" tab
    await tester.tap(find.byIcon(Icons.calculate));
    await tester.pump();

    // Verify Calculator screen appears
    expect(find.text('Calculator'), findsOneWidget);
  });

  testWidgets('Calculator performs addition', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to the calculator page
    await tester.tap(find.byIcon(Icons.calculate));
    await tester.pump();

    // Enter numbers
    await tester.enterText(find.byType(TextField).at(0), '5');
    await tester.enterText(find.byType(TextField).at(1), '3');

    // Tap on "+" button
    await tester.tap(find.text('+'));
    await tester.pump();

    // Verify the result
    expect(find.text('Result: 8.0'), findsOneWidget);
  });
}
