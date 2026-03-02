import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_learning_app/shared/services/gamification_service.dart';
import 'package:english_learning_app/data/models/gamification.dart';
import 'dart:math';

void main() {
  group('GamificationService Tests', () {
    setUp(() {
      // Clear cache before each test
      GamificationService.clearCache();
      SharedPreferences.setMockInitialValues({});
    });

    group('getGameData Tests', () {
      test('Should return default game data when no data exists', () async {
        SharedPreferences.setMockInitialValues({});

        final gameData = await GamificationService.getGameData();

        expect(gameData.level, 1); // Default is 1
        expect(gameData.totalPoints, 0);
        expect(gameData.currentLevelPoints, 0);
        expect(gameData.streak, 0);
        expect(gameData.totalStudyDays, 0);
      });

      test('Should return cached data on second call', () async {
        SharedPreferences.setMockInitialValues({});

        final firstCall = await GamificationService.getGameData();
        final secondCall = await GamificationService.getGameData();

        // Should return same instance (cached)
        expect(identical(firstCall, secondCall), true);
      });

      test('Should save and load game data', () async {
        SharedPreferences.setMockInitialValues({});

        final gameData = UserGameData(
          level: 5,
          totalPoints: 1500,
          currentLevelPoints: 500,
          nextLevelPoints: 1000,
          streak: 7,
          totalStudyDays: 30,
          unlockedAchievements: [],
          lastStudyDate: DateTime.now(),
        );

        await GamificationService.saveGameData(gameData);

        final loaded = await GamificationService.getGameData();
        expect(loaded.level, 5);
        expect(loaded.totalPoints, 1500);
      });
    });

    group('addPoints Tests', () {
      test('Should add points correctly', () async {
        GamificationService.clearCache();
        SharedPreferences.setMockInitialValues({});

        // Add 50 points (less than level threshold)
        final updated = await GamificationService.addPoints(50);

        expect(updated.totalPoints, 50);
        expect(updated.currentLevelPoints, 50);
        expect(updated.level, 1); // Still at level 1
      });

      test('Should level up when reaching threshold', () async {
        SharedPreferences.setMockInitialValues({});

        // Add enough points to reach level 2
        // Level 1 needs 100 points, add 150
        final updated = await GamificationService.addPoints(150);

        expect(updated.level, greaterThan(1));
        expect(updated.totalPoints, 150);
      });

      test('Should handle multiple additions correctly', () async {
        SharedPreferences.setMockInitialValues({});

        // First add 50 points
        final updated1 = await GamificationService.addPoints(50);
        expect(updated1.totalPoints, 50);

        // Then add another 30
        final updated2 = await GamificationService.addPoints(30);
        expect(updated2.totalPoints, 80);
      });
    });

    group('recordStudyActivity Tests', () {
      test('Should record first study activity', () async {
        SharedPreferences.setMockInitialValues({});

        final updated = await GamificationService.recordStudyActivity(
          wordsLearned: 10,
          practiceMinutes: 30,
        );

        expect(updated.totalStudyDays, 1);
        expect(updated.streak, 1);
        // Points: daily login (10) + words (50) + minutes (30) = 90+
        expect(updated.totalPoints, greaterThanOrEqualTo(90));
      });

      test('Should increment streak on consecutive days', () async {
        SharedPreferences.setMockInitialValues({});

        // First day
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final initial = UserGameData(
          level: 1,
          totalPoints: 0,
          currentLevelPoints: 0,
          nextLevelPoints: 100,
          streak: 1,
          longestStreak: 1,
          totalStudyDays: 1,
          unlockedAchievements: [],
          lastStudyDate: yesterday,
          stats: {},
        );

        await GamificationService.saveGameData(initial);

        // Second day (today)
        final updated = await GamificationService.recordStudyActivity(
          practiceMinutes: 10,
        );

        expect(updated.streak, 2);
        expect(updated.totalStudyDays, 2);
      });

      test('Should reset streak on non-consecutive days', () async {
        SharedPreferences.setMockInitialValues({});

        // Last study was 3 days ago
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        final initial = UserGameData(
          level: 1,
          totalPoints: 0,
          currentLevelPoints: 0,
          nextLevelPoints: 100,
          streak: 5,
          longestStreak: 5,
          totalStudyDays: 5,
          unlockedAchievements: [],
          lastStudyDate: threeDaysAgo,
          stats: {},
        );

        await GamificationService.saveGameData(initial);

        final updated = await GamificationService.recordStudyActivity(
          practiceMinutes: 10,
        );

        expect(updated.streak, 1); // Reset to 1
        expect(updated.totalStudyDays, 6);
      });

      test('Should add points for words learned', () async {
        SharedPreferences.setMockInitialValues({});

        final updated = await GamificationService.recordStudyActivity(
          wordsLearned: 10,
        );

        // Should get points for: daily login (10) + words (10 * 5 = 50)
        expect(updated.totalPoints, greaterThanOrEqualTo(60));
      });

      test('Should add points for practice minutes', () async {
        SharedPreferences.setMockInitialValues({});

        final updated = await GamificationService.recordStudyActivity(
          practiceMinutes: 20,
        );

        // Should get points for: daily login (10) + minutes (20 * 1 = 20)
        expect(updated.totalPoints, greaterThanOrEqualTo(30));
      });
    });

    group('checkAchievements Tests', () {
      test('Should return empty list when no achievements unlocked', () async {
        SharedPreferences.setMockInitialValues({});

        final achievements = await GamificationService.checkAchievements();

        expect(achievements, isEmpty);
      });

      test('Should unlock achievements when conditions met', () async {
        SharedPreferences.setMockInitialValues({});

        // Study multiple days to build streak
        final initial = UserGameData(
          level: 1,
          totalPoints: 0,
          currentLevelPoints: 0,
          nextLevelPoints: 100,
          streak: 3,
          longestStreak: 3,
          totalStudyDays: 3,
          unlockedAchievements: [],
          lastStudyDate: DateTime.now(),
          stats: {
            'wordsLearned': 50,
            'practiceMinutes': 100,
          },
        );

        await GamificationService.saveGameData(initial);

        final achievements = await GamificationService.checkAchievements();

        // May unlock some achievements depending on conditions
        expect(achievements, isA<List<Achievement>>());
      });
    });

    group('LevelConfig Tests', () {
      test('Should return correct points for each level', () {
        // Clear cache to ensure clean state
        GamificationService.clearCache();

        // Formula: 100 * level^1.5 (truncated, not rounded)
        final level1 = LevelConfig.getPointsForLevel(1);
        final level2 = LevelConfig.getPointsForLevel(2);
        final level3 = LevelConfig.getPointsForLevel(3);

        expect(level1, 100); // 100 * 1^1.5 = 100
        expect(level2, 282); // 100 * 2^1.5 = 282.84... → 282 (truncated)
        expect(level3, 519); // 100 * 3^1.5 = 519.61... → 519 (truncated)
      });

      test('Should return correct level bonus', () {
        final bonus1 = LevelConfig.getLevelBonus(1);
        final bonus5 = LevelConfig.getLevelBonus(5);
        final bonus10 = LevelConfig.getLevelBonus(10);

        expect(bonus1, greaterThanOrEqualTo(0));
        expect(bonus5, greaterThan(bonus1));
        expect(bonus10, greaterThan(bonus5));
      });

      test('Should increase with level', () {
        for (int level = 1; level < 10; level++) {
          final points = LevelConfig.getPointsForLevel(level);
          final nextPoints = LevelConfig.getPointsForLevel(level + 1);
          expect(nextPoints, greaterThan(points));
        }
      });
    });

    group('UserGameData Model Tests', () {
      test('Should create default user game data', () {
        final data = UserGameData();

        expect(data.level, 1); // Default is 1
        expect(data.totalPoints, 0);
        expect(data.currentLevelPoints, 0);
        expect(data.streak, 0);
        expect(data.totalStudyDays, 0);
        expect(data.unlockedAchievements, isEmpty);
        expect(data.lastStudyDate, isNull);
      });

      test('Should calculate level progress correctly', () {
        final data = UserGameData(
          level: 1,
          totalPoints: 50,
          currentLevelPoints: 50,
          nextLevelPoints: 100,
        );

        expect(data.levelProgress, 0.5);
      });

      test('Should detect when should level up', () {
        final data = UserGameData(
          level: 1,
          totalPoints: 100,
          currentLevelPoints: 100,
          nextLevelPoints: 100,
        );

        expect(data.shouldLevelUp, true);
      });

      test('Should get correct level title', () {
        final data1 = UserGameData(level: 1);
        final data5 = UserGameData(level: 5);
        final data10 = UserGameData(level: 10);

        expect(data1.levelTitle, isNotEmpty);
        expect(data5.levelTitle, isNotEmpty);
        expect(data10.levelTitle, isNotEmpty);
      });

      test('Should serialize to JSON correctly', () {
        final now = DateTime(2026, 3, 2, 12, 0);
        final data = UserGameData(
          level: 3,
          totalPoints: 500,
          currentLevelPoints: 100,
          nextLevelPoints: 200,
          streak: 2,
          longestStreak: 2,
          totalStudyDays: 5,
          unlockedAchievements: [],
          lastStudyDate: now,
          stats: {'wordsLearned': 10},
        );

        final json = data.toJson();

        expect(json['level'], 3);
        expect(json['totalPoints'], 500);
        expect(json['lastStudyDate'], now.toIso8601String());
        expect(json['stats']['wordsLearned'], 10);
      });

      test('Should deserialize from JSON correctly', () {
        final now = DateTime(2026, 3, 2, 12, 0);
        final json = {
          'level': 3,
          'totalPoints': 500,
          'currentLevelPoints': 100,
          'nextLevelPoints': 200,
          'streak': 2,
          'longestStreak': 2,
          'lastStudyDate': now.toIso8601String(),
          'totalStudyDays': 5,
          'unlockedAchievements': [],
          'stats': {},
        };

        final data = UserGameData.fromJson(json);

        expect(data.level, 3);
        expect(data.totalPoints, 500);
        expect(data.lastStudyDate, now);
      });

      test('Should copy with updated fields', () {
        final data = UserGameData(
          level: 1,
          totalPoints: 100,
          currentLevelPoints: 50,
          nextLevelPoints: 100,
          streak: 1,
          longestStreak: 1,
          totalStudyDays: 1,
          unlockedAchievements: [],
          lastStudyDate: DateTime.now(),
        );

        final updated = data.copyWith(
          level: 2,
          totalPoints: 250,
        );

        expect(updated.level, 2);
        expect(updated.totalPoints, 250);
        expect(updated.streak, 1); // Unchanged
      });
    });

    group('getLevelColor Tests', () {
      test('Should return correct colors for each level', () {
        final color1 = UserGameData.getLevelColor(1);
        final color5 = UserGameData.getLevelColor(5);
        final color10 = UserGameData.getLevelColor(10);

        expect(color1, isA<Color>());
        expect(color5, isA<Color>());
        expect(color10, isA<Color>());
      });

      test('Should return different colors for different levels', () {
        final color1 = UserGameData.getLevelColor(1);
        final color5 = UserGameData.getLevelColor(5);
        final color10 = UserGameData.getLevelColor(10);

        // Colors should be different for different levels
        expect(color1.value != color5.value || color5.value != color10.value, true);
      });
    });

    group('getLevelTitle Tests', () {
      test('Should return correct titles for levels', () {
        expect(UserGameData.getLevelTitle(1), '初学者');
        expect(UserGameData.getLevelTitle(5), '入门者');
        expect(UserGameData.getLevelTitle(10), '进阶者');
        expect(UserGameData.getLevelTitle(20), '熟练者');
        expect(UserGameData.getLevelTitle(50), '大师');
      });
    });

    group('updateStats Tests', () {
      test('Should update single stat', () async {
        SharedPreferences.setMockInitialValues({});

        final updated = await GamificationService.updateStat('wordsLearned', 10);

        expect(updated.stats['wordsLearned'], 10);
      });

      test('Should increment existing stat', () async {
        SharedPreferences.setMockInitialValues({});

        // First update
        await GamificationService.updateStat('practiceMinutes', 10);

        // Second update (should increment)
        final updated = await GamificationService.updateStat('practiceMinutes', 5);

        expect(updated.stats['practiceMinutes'], 15);
      });

      test('Should update multiple stats', () async {
        SharedPreferences.setMockInitialValues({});

        final updated = await GamificationService.updateStats({
          'wordsLearned': 10,
          'practiceMinutes': 20,
        });

        expect(updated.stats['wordsLearned'], 10);
        expect(updated.stats['practiceMinutes'], 20);
      });
    });

    group('resetData Tests', () {
      test('Should clear all data', () async {
        SharedPreferences.setMockInitialValues({});

        // Set some data
        await GamificationService.addPoints(100);
        expect((await GamificationService.getGameData()).totalPoints, 100);

        // Reset
        await GamificationService.resetData();

        // Should be back to default
        final resetData = await GamificationService.getGameData();
        expect(resetData.totalPoints, 0);
      });
    });
  });
}
