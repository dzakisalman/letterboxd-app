// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in the test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:letterboxd/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    // Initialize GetX
    Get.testMode = true;

    // Build our app with hasSeenOnboarding set to false and isLoggedIn set to false
    await tester.pumpWidget(const MyApp(
      hasSeenOnboarding: false,
      isLoggedIn: false,
    ));

    // Verify that we're on the onboarding page
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Letterboxd'), findsOneWidget);
  });

  testWidgets('App navigates to login after onboarding', (WidgetTester tester) async {
    // Initialize GetX
    Get.testMode = true;

    // Build our app with hasSeenOnboarding set to true and isLoggedIn set to false
    await tester.pumpWidget(const MyApp(
      hasSeenOnboarding: true,
      isLoggedIn: false,
    ));

    // Verify that we're on the login page
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('App navigates to home when logged in', (WidgetTester tester) async {
    // Initialize GetX
    Get.testMode = true;

    // Build our app with hasSeenOnboarding set to true and isLoggedIn set to true
    await tester.pumpWidget(const MyApp(
      hasSeenOnboarding: true,
      isLoggedIn: true,
    ));

    // Verify that we're on the home page
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byIcon(Icons.home), findsOneWidget);
  });
}
