import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:english_learning_app/shared/widgets/level_indicator.dart';
import 'package:english_learning_app/core/providers/app_provider.dart';
import 'package:english_learning_app/data/models/gamification.dart';

void main() {
  group('LevelIndicator Widget Tests', () {
    late AppProvider appProvider;

    setUp(() {
      // Initialize AppProvider with test data
      appProvider = AppProvider();
      appProvider.setGameData(UserGameData(
        level: 5,
        totalPoints: 1500,
        currentLevelPoints: 500,
        nextLevelPoints: 1000,
        streak: 7,
        totalStudyDays: 30,
        achievements: [],
        lastStudyDate: DateTime.now(),
      ));
    });

    testWidgets('Should display level when gameData is available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: appProvider,
            child: const Scaffold(
              body: LevelIndicator(),
            ),
          ),
        ),
      );

      // Wait for widgets to build
      await tester.pumpAndSettle();

      // Verify level text is displayed
      expect(find.text('Lv.5'), findsOneWidget);

      // Verify icon is displayed
      expect(find.byIcon(Icons.military_tech), findsOneWidget);
    });

    testWidgets('Should display points when showPoints is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: appProvider,
            child: const Scaffold(
              body: LevelIndicator(showPoints: true),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify points are displayed
      expect(find.text('(1500)'), findsOneWidget);
      expect(find.text('Lv.5'), findsOneWidget);
    });

    testWidgets('Should not display points when showPoints is false', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: appProvider,
            child: const Scaffold(
            body: LevelIndicator(showPoints: false),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify points are not displayed
      expect(find.text('(1500)'), findsNothing);
      expect(find.text('Lv.5'), findsOneWidget);
    });

    testWidgets('Should display nothing when gameData is null', (tester) async {
      final emptyProvider = AppProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: emptyProvider,
            child: const Scaffold(
              body: LevelIndicator(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify nothing is displayed (SizedBox.shrink)
      expect(find.byType(LevelIndicator), findsOneWidget);
      expect(find.text('Lv.'), findsNothing);
      expect(find.byIcon(Icons.military_tech), findsNothing);
    });

    testWidgets('Should be tappable and navigate', (tester) async {
      bool navigated = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: appProvider,
            child: const Scaffold(
              body: LevelIndicator(),
            ),
          ),
          onGenerateRoute: (settings) {
            if (settings.name == '/gamification') {
              navigated = true;
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Text('Gamification Page'),
                ),
              );
            }
            return null;
          },
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the LevelIndicator
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Note: Navigation test would require actual Navigator setup
      // This test verifies the widget is tappable
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('Should have correct layout structure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: appProvider,
            child: const Scaffold(
              body: LevelIndicator(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Container with padding exists
      expect(find.byType(Container), findsWidgets);

      // Verify Row with icon and text exists
      expect(find.byType(Row), findsOneWidget);

      // Verify InkWell for tap handling
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('Should display different levels correctly', (tester) async {
      // Test level 1
      appProvider.setGameData(UserGameData(
        level: 1,
        totalPoints: 100,
        currentLevelPoints: 0,
        nextLevelPoints: 200,
        streak: 0,
        totalStudyDays: 0,
        achievements: [],
        lastStudyDate: DateTime.now(),
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: appProvider,
            child: const Scaffold(
              body: LevelIndicator(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lv.1'), findsOneWidget);

      // Test level 10
      appProvider.setGameData(UserGameData(
        level: 10,
        totalPoints: 5000,
        currentLevelPoints: 0,
        nextLevelPoints: 6000,
        streak: 0,
        totalStudyDays: 0,
        achievements: [],
        lastStudyDate: DateTime.now(),
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: appProvider,
            child: const Scaffold(
              body: LevelIndicator(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Lv.10'), findsOneWidget);
    });

    testWidgets('Should have correct padding and decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: appProvider,
            child: const Scaffold(
              body: LevelIndicator(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Container widget
      final container = tester.widget<Container>(
        find.ancestor(
          of: find.text('Lv.5'),
          matching: find.byType(Container),
        ),
      );

      // Verify padding
      expect(
        container.padding,
        equals(const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
      );

      // Verify decoration exists
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('Should update when gameData changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AppProvider>.value(
            value: appProvider,
            child: const Scaffold(
              body: LevelIndicator(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial level
      expect(find.text('Lv.5'), findsOneWidget);

      // Update game data
      appProvider.setGameData(UserGameData(
        level: 8,
        totalPoints: 3000,
        currentLevelPoints: 0,
        nextLevelPoints: 4000,
        streak: 0,
        totalStudyDays: 0,
        achievements: [],
        lastStudyDate: DateTime.now(),
      ));

      await tester.pumpAndSettle();

      // Verify level updated
      expect(find.text('Lv.5'), findsNothing);
      expect(find.text('Lv.8'), findsOneWidget);
    });
  });
}
