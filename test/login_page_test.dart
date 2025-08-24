import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:green_wave_app/features/auth/presentation/login_page.dart';

void main() {
  testWidgets('email and password validation', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'wrong',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      '123',
    );
    await tester.pump();

    expect(find.text('Invalid email'), findsOneWidget);
    expect(find.text('Password too short'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'test@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      '123456',
    );
    await tester.pump();

    expect(find.text('Invalid email'), findsNothing);
    expect(find.text('Password too short'), findsNothing);
  });

  testWidgets('Create account button enabled only with valid data', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    final buttonFinder = find.widgetWithText(ElevatedButton, 'Create account');
    expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'test@example.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      '12345',
    );
    await tester.pump();
    expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      '123456',
    );
    await tester.pump();
    expect(tester.widget<ElevatedButton>(buttonFinder).onPressed, isNotNull);
  });

  testWidgets('AnimatedSwitcher changes key when slogan changes', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    expect(find.byKey(const ValueKey('login_slogan')), findsOneWidget);
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('signup_slogan')), findsOneWidget);
  });
}
