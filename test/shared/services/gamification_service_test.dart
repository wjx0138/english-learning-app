import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_learning_app/shared/services/gamification_service.dart';
import 'package:english_learning_app/data/models/gamification.dart';

void main() {
  group('GamificationService Tests', () {
    setUp(() {
      // Clear cache before each test
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
    });

    group('saveGameData Tests', () {
      test('Should save game data to preferences', () async {
        final mockPrefs = await SharedPreferences.getInstance();
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

        final saved = mockPrefs.getString('user_game_data');
        expect(saved, isNotNull);

        // Verify can be loaded back
        final loaded = await GamificationService.getGameData();
        expect(loaded.level, 5);
        expect(loaded.totalPoints, 1500);
      });
    });

    group('addPoints Tests', () {
      test('Should add points correctly', () async {
        SharedPreferences.setMockInitialValues({});

        // Add 100 points
        final updated = await GamificationService.addPoints(100);

        expect(updated.totalPoints, 100);
        expect(updated.currentLevelPoints, 100);
      });

      test('Should handle multiple level ups', () async {
        SharedPreferences.setMockInitialValues({});

        // Add enough points for multiple levels
        final updated = await GamificationService.addPoints(500);

        expect(updated.level, greaterThan(1));
        expect(updated.totalPoints, 500);
      });

      test('Should update total points correctly', () async {
        SharedPreferences.setMockInitialValues({});

        final initial = UserGameData(
          level: 2,
          totalPoints: 500,
          currentLevelPoints: 200,
          nextLevelPoints: 400,
          streak: 0,
          totalStudyDays: 0,
          unlockedAchievements: [],
          lastStudyDate: DateTime.now(),
        );

        await GamificationService.saveGameData(initial);

        final updated = await GamificationService.addPoints(50);

        expect(updated.totalPoints, 550);
      });
    });

    group('recordStudyActivity Tests', () {
      test('Should record study activity', () async {
        SharedPreferences.setMockInitialValues({});

        final updated = await GamificationService.recordStudyActivity(
          wordsLearned: 10,
          practiceMinutes: 30,
        );

        expect(updated.totalStudyDays, greaterThan(0));
        expect(updated.totalPoints, greaterThan(0)); // Should earn points
      });

      test('Should handle words learned only', () async {
        SharedPreferences.setMockInitialValues({});

        final updated = await GamificationService.recordStudyActivity(
          wordsLearned: 5,
        );

        expect(updated.totalPoints, greaterThan(0));
      });

      test('Should handle practice minutes only', () async {
        SharedPreferences.setMockInitialValues({});

        final updated = await GamificationService.recordStudyActivity(
          practiceMinutes: 15,
        );

        expect(updated.totalPoints, greaterThan(0));
      });
    });

    group('checkAchievements Tests', () {
      test('Should unlock achievements when conditions met', () async {
        SharedPreferences.setMockInitialValues({});

        // Record multiple study activities to unlock achievements
        for (int i = 0; i < 7; i++) {
          await GamificationService.recordStudyActivity(
            practiceMinutes: 10,
          );
        }

        final achievements = await GamificationService.checkAchievements();

        // Should have at least one achievement
        expect(achievements.length, greaterThan(0));
      });
    });

    group('LevelConfig Tests', () {
      test('Should return correct points for each level', () {
        expect(LevelConfig.getPointsForLevel(1), 100);
        expect(LevelConfig.getPointsForLevel(2), 200);
        expect(LevelConfig.getPointsForLevel(3), 350);
      });

      test('Should return correct level bonus', () {
        final bonus1 = LevelConfig.getLevelBonus(1);
        final bonus10 = LevelConfig.getLevelBonus(10);

        expect(bonus1, greaterThanOrEqualTo(0));
        expect(bonus10, greaterThanOrEqualTo(0));
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

      test('Should serialize to JSON correctly', () {
        final now = DateTime(2026, 3, 2, 12, 0);
        final data = UserGameData(
          level: 3,
          totalPoints: 500,
          currentLevelPoints: 100,
          nextLevelPoints: 200,
          streak: 2,
          totalStudyDays: 5,
          unlockedAchievements: [],
          lastStudyDate: now,
        );

        final json = data.toJson();

        expect(json['level'], 3);
        expect(json['totalPoints'], 500);
        expect(json['lastStudyDate'], now.toIso8601String());
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
        final color10 = UserGameData.getLevelColor(10);

        expect(color1, isNot(equals(color10)));
      });
    });
  });
}
