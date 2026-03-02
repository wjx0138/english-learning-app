import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/shared/widgets/word_card.dart';

void main() {
  group('WordCard Widget Tests', () {
    testWidgets('Should display word on front', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: 'abandon',
              definition: 'v. 遗弃；放弃',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('abandon'), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('Should display phonetic on front when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: 'ability',
              phonetic: '/əˈbɪləti/',
              definition: 'n. 能力',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('ability'), findsOneWidget);
      expect(find.text('/əˈbɪləti/'), findsOneWidget);
    });

    testWidgets('Should display definition on back when showBack is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: 'test',
              definition: 'n. 测试',
              showBack: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('test'), findsNothing);
      expect(find.text('n. 测试'), findsOneWidget);
    });

    testWidgets('Should not display definition on front', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: 'test',
              definition: 'n. 测试',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('test'), findsOneWidget);
      expect(find.text('n. 测试'), findsNothing);
    });

    testWidgets('Should call onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: 'test',
              definition: 'n. 测试',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('Should not tap when onTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: 'test',
              definition: 'n. 测试',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not throw
      await tester.tap(find.byType(Card));
      await tester.pump();

      expect(find.byType(WordCard), findsOneWidget);
    });

    testWidgets('Should have correct card styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: 'test',
              definition: 'n. 测试',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));

      expect(card.elevation, 4);
      expect(card.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('Should have correct container height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: 'test',
              definition: 'n. 测试',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Container),
        ),
      );

      expect(container.constraints?.minHeight, 300);
    });

    testWidgets('Should display word in center', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: 'center',
              definition: 'n. 中心',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final column = tester.widget<Column>(
        find.descendant(
          of: find.byType(Container),
          matching: find.byType(Column),
        ),
      );

      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('Should handle long words', (tester) async {
      const longWord = 'supercalifragilisticexpialidocious';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: longWord,
              definition: 'adj. 精彩的',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(longWord), findsOneWidget);
    });

    testWidgets('Should handle special characters', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: "don't",
              phonetic: "/doʊnt/",
              definition: 'v. 不',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text("don't"), findsOneWidget);
      expect(find.text("/doʊnt/"), findsOneWidget);
    });

    testWidgets('Should have correct text style for word', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: 'test',
              definition: 'n. 测试',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textWidget = tester.widget<Text>(find.text('test'));
      expect(textWidget.style?.fontSize, 36);
      expect(textWidget.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('Should have correct padding', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WordCard(
              word: 'test',
              definition: 'n. 测试',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Card),
          matching: find.byType(Container),
        ),
      );

      expect(container.padding, const EdgeInsets.all(24));
    });
  });
}
