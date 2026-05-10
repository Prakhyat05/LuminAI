import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luminai/main.dart';

void main() {
  testWidgets('LuminAI app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const LuminAIApp());
    // App should render the splash screen
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
