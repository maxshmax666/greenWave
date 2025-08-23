import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_wave_app/main.dart';

void main() {
  testWidgets('Email and password validation', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    final emailField = find.byType(TextFormField).first;
    final passField = find.byType(TextFormField).last;

    await tester.enterText(emailField, 'invalid');
    await tester.enterText(passField, '123');
    await tester.pump();

    expect(find.text('Invalid email'), findsOneWidget);
    expect(find.text('Min 6 chars'), findsOneWidget);

    await tester.enterText(emailField, 'user@example.com');
    await tester.enterText(passField, '123456');
    await tester.pump();

    expect(find.text('Invalid email'), findsNothing);
    expect(find.text('Min 6 chars'), findsNothing);
  });

  testWidgets('Create account button enabled only with valid data',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Switch to sign up mode
    await tester.tap(find.widgetWithText(TextButton, 'Create account'));
    await tester.pump();

    final createButton =
        find.widgetWithText(ElevatedButton, 'Create account');
    expect(
        tester.widget<ElevatedButton>(createButton).onPressed, isNull);

    await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
    await tester.enterText(find.byType(TextFormField).last, '123456');
    await tester.pump();

    expect(tester.widget<ElevatedButton>(createButton).onPressed,
        isNotNull);
  });

  testWidgets('AnimatedSwitcher changes key when slogan changes',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    final switcherFinder = find.byKey(const ValueKey('slogan-switcher'));
    AnimatedSwitcher switcher =
        tester.widget<AnimatedSwitcher>(switcherFinder);
    final firstKey = (switcher.child as Text).key;

    await tester.tap(find.widgetWithText(TextButton, 'Create account'));
    await tester.pump();
    switcher = tester.widget<AnimatedSwitcher>(switcherFinder);
    final secondKey = (switcher.child as Text).key;

    expect(firstKey, isNot(equals(secondKey)));
  });
}
