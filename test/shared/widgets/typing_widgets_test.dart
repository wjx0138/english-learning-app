import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/shared/widgets/typing_widgets.dart';

void main() {
  group('TypingInput Widget Tests', () {
    testWidgets('Should display target word', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingInput(
              targetWord: 'test',
              onTextChanged: (_) {},
              onCorrect: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('test'), findsOneWidget);
    });

    testWidgets('Should show hint text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingInput(
              targetWord: 'test',
              onTextChanged: (_) {},
              onCorrect: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Type the word above'), findsOneWidget);
    });

    testWidgets('Should call onTextChanged when typing', (tester) async {
      String? changedText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingInput(
              targetWord: 'hello',
              onTextChanged: (text) {
                changedText = text;
              },
              onCorrect: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'h');
      await tester.pump();

      expect(changedText, 'h');
    });

    testWidgets('Should validate characters', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingInput(
              targetWord: 'test',
              onTextChanged: (_) {},
              onCorrect: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter 'tex' (wrong first char)
      await tester.enterText(find.byType(TextField), 'tex');
      await tester.pump();

      // Should show red X for wrong character
      expect(find.byIcon(Icons.cancel), findsOneWidget);

      // Enter 't' (correct char)
      await tester.enterText(find.byType(TextField), 't');
      await tester.pump();

      // Should show green checkmark
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('Should call onCorrect when word completed', (tester) async {
      bool correctCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingInput(
              targetWord: 'hi',
              onTextChanged: (_) {},
              onCorrect: () {
                correctCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter correct word
      await tester.enterText(find.byType(TextField), 'hi');
      await tester.pump();

      expect(correctCalled, true);
    });

    testWidgets('Should be disabled when isEnabled is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingInput(
              targetWord: 'test',
              onTextChanged: (_) {},
              onCorrect: () {},
              isEnabled: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textField = tester.widget<TextField>(
        find.byType(TextField),
      );

      expect(textField.enabled, false);
    });

    testWidgets('Should have custom text style', (tester) async {
      const customStyle = TextStyle(fontSize: 24, color: Colors.blue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingInput(
              targetWord: 'test',
              onTextChanged: (_) {},
              onCorrect: () {},
              textStyle: customStyle,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final text = tester.widget<Text>(
        find.text('test'),
      );

      expect(text.style?.fontSize, 24);
      expect(text.style?.color, Colors.blue);
    });
  });

  group('TypingStats Widget Tests', () {
    testWidgets('Should display speed and accuracy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingStats(
              wpm: 60,
              accuracy: 0.85,
              correctCount: 17,
              totalCount: 20,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('60 WPM'), findsOneWidget);
      expect(find.text('85.0%'), findsOneWidget);
      expect(find.text('17 / 20 correct'), findsOneWidget);
    });

    testWidgets('Should show progress bar with correct color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingStats(
              wpm: 50,
              accuracy: 0.75, // Orange
              correctCount: 15,
              totalCount: 20,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Should handle 100% accuracy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingStats(
              wpm: 80,
              accuracy: 1.0,
              correctCount: 20,
              totalCount: 20,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('100.0%'), findsOneWidget);
      expect(find.text('20 / 20 correct'), findsOneWidget);
    });

    testWidgets('Should handle 0% accuracy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingStats(
              wpm: 30,
              accuracy: 0.0,
              correctCount: 0,
              totalCount: 10,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0.0%'), findsOneWidget);
      expect(find.text('0 / 10 correct'), findsOneWidget);
    });

    testWidgets('Should have correct card styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TypingStats(
              wpm: 50,
              accuracy: 0.8,
              correctCount: 8,
              totalCount: 10,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('Should calculate accuracy percentage correctly', (tester) async {
      // Test with different accuracies
      final accuracies = [0.0, 0.5, 0.75, 1.0];

      for (final accuracy in accuracies) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TypingStats(
                wpm: 50,
                accuracy: accuracy,
                correctCount: (accuracy * 10).toInt(),
                totalCount: 10,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final expectedPercentage = (accuracy * 100).toStringAsFixed(1);
        expect(find.text('$expectedPercentage%'), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });
  });

  group('TypingWidgets Integration Tests', () {
    testWidgets('Should work together in a typing session', (tester) async {
      int correctCount = 0;
      final enteredTexts = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TypingInput(
                  targetWord: 'test',
                  onTextChanged: (text) {
                    enteredTexts.add(text);
                  },
                  onCorrect: () {
                    correctCount++;
                  },
                ),
                const SizedBox(height: 20),
                TypingStats(
                  wpm: enteredTexts.length,
                  accuracy: enteredTexts.isEmpty ? 1.0 : 0.0,
                  correctCount: correctCount,
                  totalCount: 1,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate typing
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Should show correct completion
      expect(correctCount, 1);
      expect(enteredTexts, isNotEmpty);
      expect(enteredTexts.last, 'test');
    });

    testWidgets('Should handle incorrect input gracefully', (tester) async {
      bool correctCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TypingInput(
              targetWord: 'hello',
              onTextChanged: (_) {},
              onCorrect: () {
                correctCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Enter wrong word
      await tester.enterText(find.byType(TextField), 'helo');
      await tester.pump();

      // Should not call onCorrect
      expect(correctCalled, false);
    });
  });
}
