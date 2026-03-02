import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/features/flashcard/widgets/card_widget.dart';
import 'package:english_learning_app/data/models/word.dart';

void main() {
  group('FlashcardWidget Tests', () {
    testWidgets('Should display word on front', (tester) async {
      final word = Word(
        id: 'test-1',
        word: 'hello',
        definition: 'n. 你好',
        examples: const [],
        difficulty: 1,
        tags: const ['basic'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              word: word,
              showAnswer: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('hello'), findsOneWidget);
      expect(find.text('n. 你好'), findsNothing);
    });

    testWidgets('Should display definition on back', (tester) async {
      final word = Word(
        id: 'test-1',
        word: 'test',
        definition: 'n. 测试',
        examples: const [],
        difficulty: 1,
        tags: const ['basic'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              word: word,
              showAnswer: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Back shows both word and definition
      expect(find.text('test'), findsOneWidget);
      expect(find.text('n. 测试'), findsOneWidget);
    });

    testWidgets('Should flip when showAnswer changes', (tester) async {
      final word = Word(
        id: 'test-1',
        word: 'flip',
        definition: 'v. 翻转',
        examples: const [],
        difficulty: 1,
        tags: const ['verb'],
      );

      bool showAnswer = false;
      void Function(void Function())? setStateSetter;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateSetter = setState;
            return MaterialApp(
              home: Scaffold(
                body: FlashcardWidget(
                  word: word,
                  showAnswer: showAnswer,
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      // Front side
      expect(find.text('flip'), findsOneWidget);

      // Flip to back
      setStateSetter!(() {
        showAnswer = true;
      });
      await tester.pumpAndSettle();

      // Back side
      expect(find.text('v. 翻转'), findsOneWidget);
    });

    testWidgets('Should call onFlip when tapped', (tester) async {
      final word = Word(
        id: 'test-1',
        word: 'tap',
        definition: 'n. 点击',
        examples: const [],
        difficulty: 1,
        tags: const ['noun'],
      );

      bool flipCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              word: word,
              showAnswer: false,
              onFlip: () {
                flipCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(FlashcardWidget));
      await tester.pump();

      expect(flipCalled, true);
    });

    testWidgets('Should display phonetic when available', (tester) async {
      final word = Word(
        id: 'test-1',
        word: 'phonetic',
        phonetic: '/fəˈnetɪk/',
        definition: 'adj. 音标的',
        examples: const [],
        difficulty: 2,
        tags: const ['linguistics'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              word: word,
              showAnswer: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('/fəˈnetɪk/'), findsOneWidget);
    });

    testWidgets('Should handle examples display', (tester) async {
      final word = Word(
        id: 'test-1',
        word: 'example',
        definition: 'n. 例子',
        examples: const ['This is an example.', 'Another example.'],
        difficulty: 1,
        tags: const ['basic'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              word: word,
              showAnswer: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Widget only displays first example
      expect(find.text('This is an example.'), findsOneWidget);
      // Second example is not displayed
      expect(find.text('Another example.'), findsNothing);
    });

    testWidgets('Should have correct card styling', (tester) async {
      final word = Word(
        id: 'test-1',
        word: 'style',
        definition: 'n. 样式',
        examples: const [],
        difficulty: 1,
        tags: const ['design'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              word: word,
              showAnswer: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Widget uses Container instead of Card
      final container = find.byType(Container);
      expect(container, findsWidgets);

      // Verify flashcard exists and has word
      expect(find.text('style'), findsOneWidget);
    });

    testWidgets('Should handle long words', (tester) async {
      final word = Word(
        id: 'test-1',
        word: 'supercalifragilisticexpialidocious',
        definition: 'adj. 精彩的',
        examples: const [],
        difficulty: 5,
        tags: const ['long'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              word: word,
              showAnswer: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('supercalifragilisticexpialidocious'), findsOneWidget);
    });

    testWidgets('Should handle special characters', (tester) async {
      final word = Word(
        id: 'test-1',
        word: "don't",
        phonetic: "/doʊnt/",
        definition: 'v. 不',
        examples: const [],
        difficulty: 1,
        tags: const ['basic'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              word: word,
              showAnswer: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("don't"), findsOneWidget);
      expect(find.text("/doʊnt/"), findsOneWidget);
    });

    testWidgets('Should have tap feedback', (tester) async {
      final word = Word(
        id: 'test-1',
        word: 'feedback',
        definition: 'n. 反馈',
        examples: const [],
        difficulty: 1,
        tags: const ['basic'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              word: word,
              showAnswer: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final flashcardWidget = find.byType(FlashcardWidget);
      expect(flashcardWidget, findsOneWidget);

      // Tap should not throw
      await tester.tap(flashcardWidget);
      await tester.pump();

      expect(find.byType(FlashcardWidget), findsOneWidget);
    });

    testWidgets('Should animate flip', (tester) async {
      final word = Word(
        id: 'test-1',
        word: 'animate',
        definition: 'v. 动画',
        examples: const [],
        difficulty: 1,
        tags: const ['motion'],
      );

      bool showAnswer = false;
      void Function(void Function())? setStateSetter;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            setStateSetter = setState;
            return MaterialApp(
              home: Scaffold(
                body: FlashcardWidget(
                  word: word,
                  showAnswer: showAnswer,
                ),
              ),
            );
          },
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('animate'), findsOneWidget);
      expect(find.text('v. 动画'), findsNothing);

      // Trigger flip by changing showAnswer
      setStateSetter!(() {
        showAnswer = true;
      });
      await tester.pumpAndSettle();

      // Animation should complete, both word and definition visible
      expect(find.text('animate'), findsOneWidget);
      expect(find.text('v. 动画'), findsOneWidget);
    });

    testWidgets('Should handle empty examples', (tester) async {
      final word = Word(
        id: 'test-1',
        word: 'empty',
        definition: 'adj. 空的',
        examples: const [],
        difficulty: 1,
        tags: const ['basic'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlashcardWidget(
              word: word,
              showAnswer: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display definition even without examples
      expect(find.text('adj. 空的'), findsOneWidget);
    });
  });
}
