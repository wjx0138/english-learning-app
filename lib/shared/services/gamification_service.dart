import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/gamification.dart';

/// 游戏化服务 - 管理积分、等级、成就
class GamificationService {
  static const String _gameDataKey = 'user_game_data';
  static UserGameData? _cachedGameData;

  /// 获取用户游戏数据
  static Future<UserGameData> getGameData() async {
    if (_cachedGameData != null) {
      return _cachedGameData!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_gameDataKey);

      if (jsonString == null) {
        _cachedGameData = UserGameData();
        await saveGameData(_cachedGameData!);
        return _cachedGameData!;
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _cachedGameData = UserGameData.fromJson(json);
      return _cachedGameData!;
    } catch (e) {
      _cachedGameData = UserGameData();
      return _cachedGameData!;
    }
  }

  /// 保存用户游戏数据
  static Future<void> saveGameData(UserGameData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_gameDataKey, jsonEncode(data.toJson()));
      _cachedGameData = data;
    } catch (e) {
      // 忽略保存错误
    }
  }

  /// 添加积分
  static Future<UserGameData> addPoints(int points, {
    PointEventType? type,
    String? description,
  }) async {
    final gameData = await getGameData();
    final newTotalPoints = gameData.totalPoints + points;
    final newLevelPoints = gameData.currentLevelPoints + points;

    // 检查是否升级
    int newLevel = gameData.level;
    int levelPoints = newLevelPoints;
    int nextLevelPoints = gameData.nextLevelPoints;

    while (levelPoints >= nextLevelPoints) {
      levelPoints -= nextLevelPoints;
      newLevel++;
      nextLevelPoints = LevelConfig.getPointsForLevel(newLevel);
      // 升级奖励
      final bonus = LevelConfig.getLevelBonus(newLevel);
      levelPoints += bonus;
    }

    final updated = gameData.copyWith(
      totalPoints: newTotalPoints,
      level: newLevel,
      currentLevelPoints: levelPoints,
      nextLevelPoints: nextLevelPoints,
    );

    await saveGameData(updated);
    return updated;
  }

  /// 更新统计数据
  static Future<UserGameData> updateStats(Map<String, int> newStats) async {
    final gameData = await getGameData();
    final updatedStats = Map<String, int>.from(gameData.stats);

    newStats.forEach((key, value) {
      updatedStats[key] = (updatedStats[key] ?? 0) + value;
    });

    final updated = gameData.copyWith(stats: updatedStats);
    await saveGameData(updated);
    return updated;
  }

  /// 更新单个统计
  static Future<UserGameData> updateStat(String key, int value) async {
    return await updateStats({key: value});
  }

  /// 记录学习活动
  static Future<UserGameData> recordStudyActivity({
    int? wordsLearned,
    int? practiceMinutes,
    int? correctAnswers,
    int? quizScore,
  }) async {
    final gameData = await getGameData();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 检查是否是新的一天
    final lastStudy = gameData.lastStudyDate;
    final isSameDay = lastStudy != null &&
        DateTime(lastStudy.year, lastStudy.month, lastStudy.day).isAtSameMomentAs(today);

    int newStreak = gameData.streak;
    int newLongestStreak = gameData.longestStreak;
    int newTotalDays = gameData.totalStudyDays;

    if (!isSameDay) {
      // 检查是否连续
      if (lastStudy != null) {
        final yesterday = today.subtract(const Duration(days: 1));
        final lastStudyDay = DateTime(lastStudy.year, lastStudy.month, lastStudy.day);
        if (lastStudyDay.isAtSameMomentAs(yesterday)) {
          newStreak++;
        } else {
          newStreak = 1;
        }
      } else {
        newStreak = 1;
      }

      if (newStreak > newLongestStreak) {
        newLongestStreak = newStreak;
      }

      newTotalDays++;
    }

    final updated = gameData.copyWith(
      streak: newStreak,
      longestStreak: newLongestStreak,
      totalStudyDays: newTotalDays,
      lastStudyDate: now,
    );

    await saveGameData(updated);

    // 添加每日登录积分
    if (!isSameDay) {
      await addPoints(10, type: PointEventType.dailyLogin);
      // 连续学习奖励
      if (newStreak >= 3) {
        await addPoints(newStreak * 5, type: PointEventType.studyStreak);
      }
    }

    // 更新其他统计
    final statsToUpdate = <String, int>{};
    if (wordsLearned != null) {
      statsToUpdate['wordsLearned'] = wordsLearned;
      await addPoints(wordsLearned * 5, type: PointEventType.learnWord);
    }
    if (practiceMinutes != null) {
      statsToUpdate['practiceMinutes'] = practiceMinutes;
      // 每分钟获得1积分
      await addPoints(practiceMinutes, type: PointEventType.studyStreak);
    }
    if (correctAnswers != null) {
      statsToUpdate['correctAnswers'] = correctAnswers;
      await addPoints(correctAnswers * 2, type: PointEventType.correctAnswer);
    }
    if (quizScore != null) {
      final currentBest = updated.stats['highestQuizScore'] ?? 0;
      if (quizScore > currentBest) {
        statsToUpdate['highestQuizScore'] = quizScore;
      }
      if (quizScore == 100) {
        await addPoints(50, type: PointEventType.perfectQuiz);
      }
    }

    if (statsToUpdate.isNotEmpty) {
      return await updateStats(statsToUpdate);
    }

    return updated;
  }

  /// 检查并解锁成就
  static Future<List<Achievement>> checkAchievements() async {
    final gameData = await getGameData();
    final allAchievements = Achievements.getAllAchievements();
    final unlockedIds = gameData.unlockedAchievements.map((a) => a.id).toSet();
    final newlyUnlocked = <Achievement>[];

    for (final achievement in allAchievements) {
      if (!unlockedIds.contains(achievement.id)) {
        if (achievement.checkAchievement(gameData.stats)) {
          // 解锁成就
          final unlocked = achievement.copyWith(
            isUnlocked: true,
            unlockedAt: DateTime.now(),
          );
          newlyUnlocked.add(unlocked);

          // 添加成就积分
          await addPoints(achievement.points, type: PointEventType.unlockAchievement);
        }
      }
    }

    // 保存解锁的成就
    if (newlyUnlocked.isNotEmpty) {
      final updatedUnlocked = [...gameData.unlockedAchievements, ...newlyUnlocked];
      final updated = gameData.copyWith(unlockedAchievements: updatedUnlocked);
      await saveGameData(updated);
    }

    return newlyUnlocked;
  }

  /// 获取已解锁的成就
  static Future<List<Achievement>> getUnlockedAchievements() async {
    final gameData = await getGameData();
    return gameData.unlockedAchievements;
  }

  /// 获取所有成就（包括已解锁和未解锁）
  static Future<List<Achievement>> getAllAchievements() async {
    final gameData = await getGameData();
    final unlockedIds = gameData.unlockedAchievements.map((a) => a.id).toSet();
    final all = Achievements.getAllAchievements();

    return all.map((a) {
      if (unlockedIds.contains(a.id)) {
        return gameData.unlockedAchievements.firstWhere((e) => e.id == a.id);
      }
      return a;
    }).toList();
  }

  /// 重置游戏数据
  static Future<void> resetData() async {
    _cachedGameData = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameDataKey);
  }

  /// 清除缓存
  static void clearCache() {
    _cachedGameData = null;
  }
}
