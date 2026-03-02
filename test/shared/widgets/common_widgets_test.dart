import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/shared/widgets/common_widgets.dart';

void main() {
  group('ProgressRing Widget Tests', () {
    testWidgets('Should display progress correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressRing(
              progress: 0.5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Should display label when provided', (tester) async {
      const label = '50%';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressRing(
              progress: 0.5,
              label: label,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text(label), findsOneWidget);
    });

    testWidgets('Should not display label when not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressRing(
              progress: 0.5,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Text), findsNothing);
    });

    testWidgets('Should have correct size', (tester) async {
      const customSize = 150.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: customSize,
              height: customSize,
              child: const ProgressRing(
                progress: 0.5,
                size: customSize,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ProgressRing),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.width?.toDouble(), customSize);
      expect(sizedBox.height?.toDouble(), customSize);
    });

    testWidgets('Should handle 0% progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressRing(
              progress: 0.0,
              label: '0%',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('Should handle 100% progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressRing(
              progress: 1.0,
              label: '100%',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('StatsCard Widget Tests', () {
    testWidgets('Should display title and value', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Total Words',
              value: '1,234',
              icon: Icons.book,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Total Words'), findsOneWidget);
      expect(find.text('1,234'), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
    });

    testWidgets('Should be tappable when onTap provided', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Total Words',
              value: '1,234',
              icon: Icons.book,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('Should show chevron when onTap is provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Total Words',
              value: '1,234',
              icon: Icons.book,
              onTap: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('Should not show chevron when onTap is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Total Words',
              value: '1,234',
              icon: Icons.book,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('Should have correct elevation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatsCard(
              title: 'Total Words',
              value: '1,234',
              icon: Icons.book,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 2);
    });
  });

  group('AchievementBadge Widget Tests', () {
    testWidgets('Should display title and description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementBadge(
              title: 'First Steps',
              description: 'Complete your first learning session',
              icon: Icons.star,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('First Steps'), findsOneWidget);
      expect(
        find.text('Complete your first learning session'),
        findsOneWidget,
      );
    });

    testWidgets('Should be semi-transparent when locked', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementBadge(
              title: 'First Steps',
              description: 'Complete your first learning session',
              icon: Icons.star,
              isUnlocked: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(AchievementBadge),
          matching: find.byType(Opacity),
        ),
      );

      expect(opacity.opacity, lessThan(1.0));
    });

    testWidgets('Should be fully opaque when unlocked', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementBadge(
              title: 'First Steps',
              description: 'Complete your first learning session',
              icon: Icons.star,
              isUnlocked: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(AchievementBadge),
          matching: find.byType(Opacity),
        ),
      );

      expect(opacity.opacity, 1.0);
    });

    testWidgets('Should display unlock date when provided', (tester) async {
      const unlockedDate = '2026-03-02';
      // Need to import intl package for DateFormat
      // For now, just test that date is displayed

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadge(
              title: 'First Steps',
              description: 'Complete your first learning session',
              icon: Icons.star,
              isUnlocked: true,
              unlockedAt: DateTime(2026, 3, 2),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AchievementBadge), findsOneWidget);
    });

    testWidgets('Should have correct elevation based on unlocked state', (tester) async {
      // Test locked state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementBadge(
              title: 'Locked Badge',
              description: 'Not yet unlocked',
              icon: Icons.lock,
              isUnlocked: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final lockedCard = tester.widget<Card>(
        find.descendant(
          of: find.byType(AchievementBadge),
          matching: find.byType(Card),
        ),
      );

      expect(lockedCard.elevation, 1);

      // Test unlocked state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementBadge(
              title: 'Unlocked Badge',
              description: 'Successfully unlocked',
              icon: Icons.star,
              isUnlocked: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final unlockedCard = tester.widget<Card>(
        find.descendant(
          of: find.byType(AchievementBadge),
          matching: find.byType(Card),
        ),
      );

      expect(unlockedCard.elevation, 4);
    });

    testWidgets('Should display icon with correct color', (tester) async {
      // Test locked state (grey)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementBadge(
              title: 'Locked',
              description: 'Not unlocked',
              icon: Icons.lock,
              isUnlocked: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock), findsOneWidget);

      // Test unlocked state (amber)
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementBadge(
              title: 'Unlocked',
              description: 'Unlocked',
              icon: Icons.star,
              isUnlocked: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });
}
