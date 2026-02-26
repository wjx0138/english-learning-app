import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Progress tracking provider for learning statistics
class ProgressProvider extends ChangeNotifier {
  // Learning statistics
  int _totalStudyDays = 0;
  int _totalCardsStudied = 0;
  int _totalCorrectAnswers = 0;
  int _totalWrongAnswers = 0;
  int _currentStreak = 0; // Consecutive days
  int _longestStreak = 0;
  DateTime? _lastStudyDate;

  // Weekly study data (for chart)
  final Map<int, int> _weeklyStudyData = {};
  DateTime? _weekStartDate; // Track current week start date

  // Vocabulary tracking - now tracks correct count for each word
  static const int _totalVocabularySize = 100; // Total words in current deck
  static const int _masteryThreshold = 3; // Need 3 correct answers to master a word
  final Map<String, int> _wordCorrectCounts = {}; // word ID -> correct count

  // Daily goal setting
  int _dailyGoal = 20; // Default: 20 cards per day

  // Achievement badges
  final List<Achievement> _achievements = [
    Achievement(
      id: 'first_study',
      title: '初学者',
      description: '完成第一次学习',
      icon: Icons.star,
      requirement: 1,
      current: 0,
      category: AchievementCategory.learning,
    ),
    Achievement(
      id: 'ten_cards',
      title: '勤奋',
      description: '学习10张卡片',
      icon: Icons.workspace_premium,
      requirement: 10,
      current: 0,
      category: AchievementCategory.learning,
    ),
    Achievement(
      id: 'hundred_cards',
      title: '百次学习',
      description: '学习100张卡片',
      icon: Icons.military_tech,
      requirement: 100,
      current: 0,
      category: AchievementCategory.learning,
    ),
    Achievement(
      id: 'streak_7',
      title: '坚持一周',
      description: '连续学习7天',
      icon: Icons.calendar_today,
      requirement: 7,
      current: 0,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'streak_30',
      title: '月度冠军',
      description: '连续学习30天',
      icon: Icons.emoji_events,
      requirement: 30,
      current: 0,
      category: AchievementCategory.streak,
    ),
    Achievement(
      id: 'perfect_100',
      title: '完美主义',
      description: '单次正确率达到100%',
      icon: Icons.grade,
      requirement: 1,
      current: 0,
      category: AchievementCategory.accuracy,
    ),
    Achievement(
      id: 'vocab_10',
      title: '初识单词',
      description: '掌握10个单词',
      icon: Icons.menu_book,
      requirement: 10,
      current: 0,
      category: AchievementCategory.learning,
    ),
    Achievement(
      id: 'vocab_50',
      title: '词汇达人',
      description: '掌握50个单词',
      icon: Icons.book,
      requirement: 50,
      current: 0,
      category: AchievementCategory.learning,
    ),
    Achievement(
      id: 'vocab_100',
      title: '词汇大师',
      description: '掌握100个单词',
      icon: Icons.school,
      requirement: 100,
      current: 0,
      category: AchievementCategory.learning,
    ),
  ];

  // Getters
  int get totalStudyDays => _totalStudyDays;
  int get totalCardsStudied => _totalCardsStudied;
  int get totalCorrectAnswers => _totalCorrectAnswers;
  int get totalWrongAnswers => _totalWrongAnswers;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  DateTime? get lastStudyDate => _lastStudyDate;
  Map<int, int> get weeklyStudyData => Map.unmodifiable(_weeklyStudyData);
  List<Achievement> get achievements => List.unmodifiable(_achievements);

  double get overallAccuracy {
    final total = _totalCorrectAnswers + _totalWrongAnswers;
    if (total == 0) return 0.0;
    return _totalCorrectAnswers / total;
  }

  int get dailyGoal => _dailyGoal;

  // Count words that have reached mastery threshold
  int get learnedVocabularyCount =>
      _wordCorrectCounts.values.where((count) => count >= _masteryThreshold).length;

  int get totalVocabularySize => _totalVocabularySize;
  double get vocabularyProgress =>
      _totalVocabularySize > 0 ? learnedVocabularyCount / _totalVocabularySize : 0.0;

  /// Initialize progress data from shared preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    _totalStudyDays = prefs.getInt('total_study_days') ?? 0;
    _totalCardsStudied = prefs.getInt('total_cards_studied') ?? 0;
    _totalCorrectAnswers = prefs.getInt('total_correct_answers') ?? 0;
    _totalWrongAnswers = prefs.getInt('total_wrong_answers') ?? 0;
    _currentStreak = prefs.getInt('current_streak') ?? 0;
    _longestStreak = prefs.getInt('longest_streak') ?? 0;
    _dailyGoal = prefs.getInt('daily_goal') ?? 20;

    final lastStudyDateStr = prefs.getString('last_study_date');
    if (lastStudyDateStr != null) {
      _lastStudyDate = DateTime.parse(lastStudyDateStr);
      _checkAndUpdateStreak();
    }

    // Load week start date and check if week needs reset
    final weekStartDateStr = prefs.getString('week_start_date');
    if (weekStartDateStr != null) {
      _weekStartDate = DateTime.parse(weekStartDateStr);
      _checkAndResetWeeklyData();
    } else {
      // First time, set current week start
      _setWeekStartDate();
    }

    // Load weekly data
    for (int i = 0; i < 7; i++) {
      final key = 'weekly_day_$i';
      _weeklyStudyData[i] = prefs.getInt(key) ?? 0;
    }

    // Load achievement progress
    for (var achievement in _achievements) {
      final key = 'achievement_${achievement.id}';
      achievement.current = prefs.getInt(key) ?? 0;
    }

    // Load word correct counts
    final wordCountsStr = prefs.getString('word_correct_counts');
    if (wordCountsStr != null) {
      final Map<String, dynamic> decoded = json.decode(wordCountsStr);
      _wordCorrectCounts.clear();
      decoded.forEach((key, value) {
        _wordCorrectCounts[key] = value as int;
      });
    }

    notifyListeners();
  }

  /// Record a study session
  Future<void> recordStudySession({
    required int cardsStudied,
    required int correctAnswers,
    required int wrongAnswers,
    List<String>? correctWordIds,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    _totalCardsStudied += cardsStudied;
    _totalCorrectAnswers += correctAnswers;
    _totalWrongAnswers += wrongAnswers;

    // Track learned vocabulary with correct counts
    if (correctWordIds != null) {
      for (var wordId in correctWordIds) {
        _wordCorrectCounts[wordId] = (_wordCorrectCounts[wordId] ?? 0) + 1;
      }
      // Save word counts as JSON
      await prefs.setString('word_correct_counts', json.encode(_wordCorrectCounts));
    }

    // Update study day
    final today = DateTime.now();
    final weekday = today.weekday - 1; // Convert to 0-6 (Monday-Sunday)
    _weeklyStudyData[weekday] = (_weeklyStudyData[weekday] ?? 0) + cardsStudied;

    await prefs.setInt('total_cards_studied', _totalCardsStudied);
    await prefs.setInt('total_correct_answers', _totalCorrectAnswers);
    await prefs.setInt('total_wrong_answers', _totalWrongAnswers);
    await prefs.setInt('weekly_day_$weekday', _weeklyStudyData[weekday]!);

    await _updateStudyDate(prefs);
    await _checkAndUnlockAchievements();

    notifyListeners();
  }

  /// Update study date and streak
  Future<void> _updateStudyDate(SharedPreferences prefs) async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (_lastStudyDate != null) {
      final lastDate = DateTime(
        _lastStudyDate!.year,
        _lastStudyDate!.month,
        _lastStudyDate!.day,
      );

      if (lastDate.isAtSameMomentAs(todayDate)) {
        // Already studied today, don't increment streak
        return;
      }

      final difference = todayDate.difference(lastDate).inDays;
      if (difference == 1) {
        // Consecutive day
        _currentStreak++;
        if (_currentStreak > _longestStreak) {
          _longestStreak = _currentStreak;
        }
      } else {
        // Streak broken
        _currentStreak = 1;
      }
    } else {
      // First study session
      _currentStreak = 1;
      _longestStreak = 1;
    }

    _lastStudyDate = today;
    await prefs.setString('last_study_date', today.toIso8601String());
    await prefs.setInt('current_streak', _currentStreak);
    await prefs.setInt('longest_streak', _longestStreak);
    await prefs.setInt('total_study_days', _totalStudyDays + 1);

    _totalStudyDays++;
  }

  /// Check if streak should be reset (called on app start)
  void _checkAndUpdateStreak() {
    if (_lastStudyDate == null) return;

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final lastDate = DateTime(
      _lastStudyDate!.year,
      _lastStudyDate!.month,
      _lastStudyDate!.day,
    );

    final difference = todayDate.difference(lastDate).inDays;
    if (difference > 1) {
      // Streak broken
      _currentStreak = 0;
    }
  }

  /// Check and unlock achievements
  Future<void> _checkAndUnlockAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    bool changed = false;

    for (var achievement in _achievements) {
      int oldValue = achievement.current;
      int newValue = achievement.current;

      switch (achievement.id) {
        case 'first_study':
          newValue = _totalStudyDays >= 1 ? 1 : 0;
          break;
        case 'ten_cards':
          newValue = _totalCardsStudied >= 10 ? 1 : 0;
          break;
        case 'hundred_cards':
          newValue = _totalCardsStudied >= 100 ? 1 : 0;
          break;
        case 'streak_7':
          newValue = _longestStreak >= 7 ? 1 : 0;
          break;
        case 'streak_30':
          newValue = _longestStreak >= 30 ? 1 : 0;
          break;
        case 'perfect_100':
          // Check if last session had 100% accuracy with at least 5 cards
          // This would need to be tracked per session
          newValue = 0; // TODO: Implement per-session accuracy tracking
          break;
        case 'vocab_10':
          newValue = learnedVocabularyCount >= 10 ? 1 : 0;
          break;
        case 'vocab_50':
          newValue = learnedVocabularyCount >= 50 ? 1 : 0;
          break;
        case 'vocab_100':
          newValue = learnedVocabularyCount >= 100 ? 1 : 0;
          break;
      }

      if (newValue != oldValue) {
        achievement.current = newValue;
        await prefs.setInt('achievement_${achievement.id}', newValue);
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// Reset all progress (for testing purposes)
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await initialize();
  }

  /// Set current week start date
  void _setWeekStartDate() {
    _weekStartDate = DateTime.now();
  }

  /// Check if week needs reset and reset weekly data
  void _checkAndResetWeeklyData() {
    if (_weekStartDate == null) return;

    final now = DateTime.now();
    final weekFromNow = DateTime(now.year, now.month, now.day);
    final daysSinceWeekStart = weekFromNow.difference(_weekStartDate!).inDays;

    // Reset weekly data if a new week started (7+ days)
    if (daysSinceWeekStart >= 7) {
      for (int i = 0; i < 7; i++) {
        _weeklyStudyData[i] = 0;
      }
      _setWeekStartDate();
    }
  }

  /// Update daily learning goal
  Future<void> setDailyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    _dailyGoal = goal.clamp(5, 100); // Limit between 5-100
    await prefs.setInt('daily_goal', _dailyGoal);
    notifyListeners();
  }
}

/// Achievement model

/// Achievement model
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int requirement;
  int current;
  final AchievementCategory category;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requirement,
    required this.category,
    this.current = 0,
  });

  double get progress => requirement > 0 ? current / requirement : 0;
  bool get isUnlocked => current >= requirement;
}

enum AchievementCategory {
  learning,
  streak,
  accuracy,
}
