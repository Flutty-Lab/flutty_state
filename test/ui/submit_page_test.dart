import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutty_state/ui/submit_page.dart';

void main() {
  group('SubmitPage Widget Tests', () {
    testWidgets('should display initial content', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: SubmitPage(
            childBuilder: (submitter, context) => const Text('Submit Form'),
          ),
        ),
      );

      // Assert - Vérifie que le contenu initial est affiché
      expect(find.text('Submit Form'), findsOneWidget);
    });
  });
}
