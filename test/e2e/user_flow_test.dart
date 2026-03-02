import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_learning_app/main.dart';
import 'package:provider/provider.dart';
import 'package:english_learning_app/core/providers/app_provider.dart';
import 'package:english_learning_app/core/providers/card_provider.dart';
import 'package:english_learning_app/core/providers/progress_provider.dart';
import 'package:english_learning_app/core/providers/quiz_provider.dart';
import 'package:english_learning_app/shared/services/gamification_service.dart';
import 'package:english_learning_app/shared/widgets/common_widgets.dart';
import 'package:english_learning_app/shared/widgets/typing_widgets.dart';

void main() {
  // Setup SharedPreferences mock for all tests
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });
  group('Widget Component Integration Tests', () {
    testWidgets('Should display ProgressRing in context', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: ProgressRing(
                progress: 0.75,
                label: '75%',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProgressRing), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('Should display StatsCard in context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                StatsCard(
                  title: 'Total Words',
                  value: '1,234',
                  icon: Icons.book,
                ),
                StatsCard(
                  title: 'Study Streak',
                  value: '7 days',
                  icon: Icons.local_fire_department,
                  onTap: null,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(StatsCard), findsNWidgets(2));
      expect(find.text('Total Words'), findsOneWidget);
      expect(find.text('1,234'), findsOneWidget);
      expect(find.text('Study Streak'), findsOneWidget);
      expect(find.text('7 days'), findsOneWidget);
    });

    testWidgets('Should display AchievementBadge in context', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: const [
                AchievementBadge(
                  title: 'First Steps',
                  description: 'Complete your first session',
                  icon: Icons.star,
                  isUnlocked: true,
                ),
                AchievementBadge(
                  title: 'Word Master',
                  description: 'Learn 100 words',
                  icon: Icons.emoji_events,
                  isUnlocked: false,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AchievementBadge), findsNWidgets(2));
      expect(find.text('First Steps'), findsOneWidget);
      expect(find.text('Word Master'), findsOneWidget);
    });

    testWidgets('Should display TypingInput and TypingStats', (tester) async {
      int correctCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TypingInput(
                  targetWord: 'hello',
                  onTextChanged: (text) {},
                  onCorrect: () {
                    correctCount++;
                  },
                ),
                const SizedBox(height: 20),
                TypingStats(
                  wpm: 40,
                  accuracy: 0.85,
                  correctCount: 17,
                  totalCount: 20,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TypingInput), findsOneWidget);
      expect(find.byType(TypingStats), findsOneWidget);
      expect(find.text('hello'), findsOneWidget);
      expect(find.text('40 WPM'), findsOneWidget);
      expect(find.text('85.0%'), findsOneWidget);
    });

    testWidgets('Should handle combined widget layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  ProgressRing(
                    progress: 0.6,
                    size: 120,
                    label: '60%',
                  ),
                  SizedBox(height: 20),
                  StatsCard(
                    title: 'Accuracy',
                    value: '85%',
                    icon: Icons.check_circle,
                  ),
                  SizedBox(height: 10),
                  StatsCard(
                    title: 'Speed',
                    value: '45 WPM',
                    icon: Icons.speed,
                  ),
                  SizedBox(height: 20),
                  AchievementBadge(
                    title: 'Quick Learner',
                    description: 'Complete 10 words in 1 minute',
                    icon: Icons.timer,
                    isUnlocked: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProgressRing), findsOneWidget);
      expect(find.byType(StatsCard), findsNWidgets(2));
      expect(find.byType(AchievementBadge), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('45 WPM'), findsOneWidget);
    });
  });

  group('State Management Integration Tests', () {
    testWidgets('Should integrate with AppProvider', (tester) async {
      final appProvider = AppProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appProvider,
          child: MaterialApp(
            home: Consumer<AppProvider>(
              builder: (context, app, child) {
                return Scaffold(
                  body: Center(
                    child: Text('Level: ${app.level}'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app provider is working
      expect(find.text('Level: 1'), findsOneWidget);
      expect(appProvider.currentIndex, 0);

      // Change index
      appProvider.setIndex(1);
      await tester.pump();

      expect(appProvider.currentIndex, 1);
    });

    testWidgets('Should update UI on state change', (tester) async {
      final appProvider = AppProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appProvider,
          child: MaterialApp(
            home: Consumer<AppProvider>(
              builder: (context, app, child) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      children: [
                        Text('Current index: ${app.currentIndex}'),
                        Text('Level: ${app.level}'),
                        Text('Points: ${app.totalPoints}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Current index: 0'), findsOneWidget);
      expect(find.text('Level: 1'), findsOneWidget);
      expect(find.text('Points: 0'), findsOneWidget);

      // Change state
      appProvider.setIndex(2);
      await tester.pump();

      expect(find.text('Current index: 2'), findsOneWidget);
    });
  });

  group('Gamification Integration Tests', () {
    testWidgets('Should add points correctly', (tester) async {
      GamificationService.clearCache();
      SharedPreferences.setMockInitialValues({});

      await AppProvider().initGameData();

      final initialData = await GamificationService.getGameData();
      final initialPoints = initialData?.totalPoints ?? 0;

      // Add points
      await GamificationService.addPoints(100);

      final updatedData = await GamificationService.getGameData();
      final updatedPoints = updatedData?.totalPoints ?? 0;

      // Verify points increased
      expect(updatedPoints, greaterThanOrEqualTo(initialPoints + 100));
    });

    testWidgets('Should record study activity', (tester) async {
      GamificationService.clearCache();
      SharedPreferences.setMockInitialValues({});

      await AppProvider().initGameData();

      final initialData = await GamificationService.getGameData();
      final initialPoints = initialData?.totalPoints ?? 0;

      // Record activity
      await GamificationService.recordStudyActivity(
        wordsLearned: 10,
        practiceMinutes: 5,
      );

      final updatedData = await GamificationService.getGameData();
      final updatedPoints = updatedData?.totalPoints ?? 0;

      // Verify points increased
      expect(updatedPoints, greaterThan(initialPoints));
    });

    testWidgets('Should unlock achievements', (tester) async {
      GamificationService.clearCache();
      SharedPreferences.setMockInitialValues({});

      await AppProvider().initGameData();
      await GamificationService.addPoints(500);

      final achievements = await GamificationService.checkAchievements();

      // Should have achievements list
      expect(achievements, isNotNull);
    });

    testWidgets('Should display correct level', (tester) async {
      GamificationService.clearCache();
      SharedPreferences.setMockInitialValues({});

      await AppProvider().initGameData();
      await GamificationService.addPoints(1000);

      final data = await GamificationService.getGameData();

      expect(data, isNotNull);
      expect(data!.level, greaterThan(0));
      expect(data.totalPoints, 1000);
    });
  });

  group('Typing Flow Integration Tests', () {
    testWidgets('Should complete typing workflow', (tester) async {
      final typedWords = <String>[];
      int correctCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TypingInput(
                  targetWord: 'test',
                  onTextChanged: (text) {
                    typedWords.add(text);
                  },
                  onCorrect: () {
                    correctCount++;
                  },
                ),
                const SizedBox(height: 20),
                TypingStats(
                  wpm: typedWords.length,
                  accuracy: typedWords.isEmpty ? 1.0 : 0.0,
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

      // Verify typing workflow
      expect(correctCount, 1);
      expect(typedWords, isNotEmpty);
      expect(typedWords.last, 'test');
    });

    testWidgets('Should handle incorrect typing', (tester) async {
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
      await tester.enterText(find.byType(TextField), 'hell');
      await tester.pump();

      // Should not call onCorrect
      expect(correctCalled, false);
    });

    testWidgets('Should update typing stats in real-time', (tester) async {
      final enteredTexts = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                TypingInput(
                  targetWord: 'word',
                  onTextChanged: (text) {
                    enteredTexts.add(text);
                  },
                  onCorrect: () {},
                ),
                const SizedBox(height: 20),
                TypingStats(
                  wpm: enteredTexts.length * 10,
                  accuracy: enteredTexts.isNotEmpty ? 0.8 : 1.0,
                  correctCount: enteredTexts.length,
                  totalCount: enteredTexts.length + 1,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Type the word
      await tester.enterText(find.byType(TextField), 'word');
      await tester.pump();

      // Verify stats updated
      expect(enteredTexts, isNotEmpty);
    });
  });

  group('Error Handling Flow Tests', () {
    testWidgets('Should handle missing data gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatsCard(
                  title: 'Test',
                  value: '0',
                  icon: Icons.question_mark,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display without crashing
      expect(find.byType(StatsCard), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('Should handle zero progress correctly', (tester) async {
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

      expect(find.byType(ProgressRing), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('Should handle full progress correctly', (tester) async {
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

      expect(find.byType(ProgressRing), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('Should handle locked achievement', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementBadge(
              title: 'Locked Achievement',
              description: 'Not yet unlocked',
              icon: Icons.lock,
              isUnlocked: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AchievementBadge), findsOneWidget);
      expect(find.text('Locked Achievement'), findsOneWidget);

      // Check for opacity widget
      final opacity = tester.widget<Opacity>(
        find.descendant(
          of: find.byType(AchievementBadge),
          matching: find.byType(Opacity),
        ),
      );

      expect(opacity.opacity, lessThan(1.0));
    });
  });

  group('Performance Flow Tests', () {
    testWidgets('Should render widgets quickly', (tester) async {
      final Stopwatch stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ProgressRing(progress: 0.5, label: '50%'),
                StatsCard(title: 'Test', value: '100', icon: Icons.star),
                AchievementBadge(
                  title: 'Test',
                  description: 'Test achievement',
                  icon: Icons.emoji_events,
                  isUnlocked: true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should render within 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('Should handle rapid state changes', (tester) async {
      final appProvider = AppProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: appProvider,
          child: MaterialApp(
            home: Consumer<AppProvider>(
              builder: (context, app, child) {
                return Scaffold(
                  body: Center(
                    child: Text('Index: ${app.currentIndex}'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final Stopwatch stopwatch = Stopwatch()..start();

      // Rapid state changes
      for (int i = 0; i < 10; i++) {
        appProvider.setIndex(i);
        await tester.pump();
      }

      stopwatch.stop();

      // Should handle 10 changes quickly (< 500ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    testWidgets('Should handle multiple widget updates', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 10; i++)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ProgressRing(
                        key: ValueKey(i),
                        progress: i / 10,
                        label: '${i * 10}%',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );

      final Stopwatch stopwatch = Stopwatch()..start();

      await tester.pumpAndSettle();
      stopwatch.stop();

      // Should render 10 widgets quickly (< 1 second)
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(find.byType(ProgressRing), findsNWidgets(10));
    });
  });
}
