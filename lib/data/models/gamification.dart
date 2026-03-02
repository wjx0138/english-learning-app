import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 用户游戏数据
class UserGameData {
  final int totalPoints;        // 总积分
  final int level;              // 等级
  final int currentLevelPoints; // 当前等级积分
  final int nextLevelPoints;    // 下一等级所需积分
  final int streak;             // 连续学习天数
  final int longestStreak;      // 最长连续天数
  final DateTime? lastStudyDate;// 最后学习日期
  final int totalStudyDays;     // 总学习天数
  final List<Achievement> unlockedAchievements;
  final Map<String, int> stats; // 各种统计数据

  UserGameData({
    this.totalPoints = 0,
    this.level = 1,
    this.currentLevelPoints = 0,
    this.nextLevelPoints = 100,
    this.streak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
    this.totalStudyDays = 0,
    this.unlockedAchievements = const [],
    this.stats = const {},
  });

  /// 获取等级进度百分比
  double get levelProgress {
    if (nextLevelPoints == 0) return 0.0;
    return currentLevelPoints / nextLevelPoints;
  }

  /// 获取等级称号
  String get levelTitle => getLevelTitle(level);

  /// 检查是否需要升级
  bool get shouldLevelUp => currentLevelPoints >= nextLevelPoints;

  /// 计算下一等级
  int get nextLevel => level + 1;

  UserGameData copyWith({
    int? totalPoints,
    int? level,
    int? currentLevelPoints,
    int? nextLevelPoints,
    int? streak,
    int? longestStreak,
    DateTime? lastStudyDate,
    int? totalStudyDays,
    List<Achievement>? unlockedAchievements,
    Map<String, int>? stats,
  }) {
    return UserGameData(
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      currentLevelPoints: currentLevelPoints ?? this.currentLevelPoints,
      nextLevelPoints: nextLevelPoints ?? this.nextLevelPoints,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      totalStudyDays: totalStudyDays ?? this.totalStudyDays,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      stats: stats ?? this.stats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'level': level,
      'currentLevelPoints': currentLevelPoints,
      'nextLevelPoints': nextLevelPoints,
      'streak': streak,
      'longestStreak': longestStreak,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
      'totalStudyDays': totalStudyDays,
      'unlockedAchievements': unlockedAchievements.map((a) => a.id).toList(),
      'stats': stats,
    };
  }

  factory UserGameData.fromJson(Map<String, dynamic> json) {
    return UserGameData(
      totalPoints: json['totalPoints'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      currentLevelPoints: json['currentLevelPoints'] as int? ?? 0,
      nextLevelPoints: json['nextLevelPoints'] as int? ?? 100,
      streak: json['streak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.parse(json['lastStudyDate'] as String)
          : null,
      totalStudyDays: json['totalStudyDays'] as int? ?? 0,
      unlockedAchievements: [],
      stats: Map<String, int>.from(json['stats'] as Map? ?? {}),
    );
  }

  static String getLevelTitle(int level) {
    if (level < 5) return '初学者';
    if (level < 10) return '入门者';
    if (level < 20) return '进阶者';
    if (level < 30) return '熟练者';
    if (level < 40) return '精通者';
    if (level < 50) return '专家';
    if (level < 60) return '大师';
    if (level < 70) return '宗师';
    if (level < 80) return '传奇';
    if (level < 90) return '史诗';
    return '神话';
  }

  /// 获取等级颜色
  static Color getLevelColor(int level) {
    if (level < 5) return Colors.grey;
    if (level < 10) return Colors.green;
    if (level < 20) return Colors.lightGreen;
    if (level < 30) return Colors.blue;
    if (level < 40) return Colors.indigo;
    if (level < 50) return Colors.purple;
    if (level < 60) return Colors.orange;
    if (level < 70) return Colors.red;
    if (level < 80) return Colors.deepOrange;
    if (level < 90) return Colors.pink;
    return Colors.amber;
  }
}

/// 成就
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int points;        // 完成成就获得的积分
  final AchievementType type;
  final Map<String, int> requirement; // 完成要求
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.points = 50,
    required this.type,
    required this.requirement,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  /// 检查是否达成
  bool checkAchievement(Map<String, int> userStats) {
    switch (type) {
      case AchievementType.wordsLearned:
        final target = requirement['count'] ?? 0;
        return (userStats['wordsLearned'] ?? 0) >= target;
      case AchievementType.studyDays:
        final target = requirement['days'] ?? 0;
        return (userStats['studyDays'] ?? 0) >= target;
      case AchievementType.streak:
        final target = requirement['days'] ?? 0;
        return (userStats['longestStreak'] ?? 0) >= target;
      case AchievementType.quizScore:
        final target = requirement['score'] ?? 0;
        return (userStats['highestQuizScore'] ?? 0) >= target;
      case AchievementType.practiceTime:
        final target = requirement['minutes'] ?? 0;
        return (userStats['practiceMinutes'] ?? 0) >= target;
    }
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    int? points,
    AchievementType? type,
    Map<String, int>? requirement,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      points: points ?? this.points,
      type: type ?? this.type,
      requirement: requirement ?? this.requirement,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'type': type.name,
      'requirement': requirement,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: _getIconFromString(json['icon'] as String? ?? 'star'),
      points: json['points'] as int? ?? 50,
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.wordsLearned,
      ),
      requirement: Map<String, int>.from(json['requirement'] as Map? ?? {}),
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }

  static IconData _getIconFromString(String iconStr) {
    switch (iconStr) {
      case 'school': return Icons.school;
      case 'local_fire_department': return Icons.local_fire_department;
      case 'emoji_events': return Icons.emoji_events;
      case 'military_tech': return Icons.military_tech;
      case 'stars': return Icons.stars;
      case 'workspace_premium': return Icons.workspace_premium;
      default: return Icons.star;
    }
  }
}

/// 成就类型
enum AchievementType {
  wordsLearned,    // 学习单词数
  studyDays,       // 学习天数
  streak,          // 连续打卡
  quizScore,       // 测验分数
  practiceTime,    // 练习时长
}

/// 积分获取事件
class PointEvent {
  final String id;
  final String description;
  final int points;
  final PointEventType type;

  PointEvent({
    required this.id,
    required this.description,
    required this.points,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'points': points,
      'type': type.name,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// 积分事件类型
enum PointEventType {
  dailyLogin,       // 每日登录
  learnWord,        // 学习新单词
  reviewCard,       // 复习卡片
  completeQuiz,     // 完成测验
  perfectQuiz,      // 完美测验
  correctAnswer,    // 答对题目
  unlockAchievement,// 解锁成就
  levelUp,          // 升级
  studyStreak,      // 连续学习
}

/// 等级奖励配置
class LevelConfig {
  static int getPointsForLevel(int level) {
    // 经验值公式: 100 * level^1.5
    return (100 * math.pow(level.toDouble(), 1.5)).toInt();
  }

  static int getLevelBonus(int level) {
    // 升级奖励积分
    return level * 100;
  }
}

/// 预定义成就
class Achievements {
  static List<Achievement> getAllAchievements() {
    return [
      // 学习成就
      Achievement(
        id: 'first_steps',
        title: '初露锋芒',
        description: '学习第1个单词',
        icon: Icons.school,
        points: 10,
        type: AchievementType.wordsLearned,
        requirement: {'count': 1},
      ),
      Achievement(
        id: 'word_collector_10',
        title: '词汇收集者',
        description: '学习10个单词',
        icon: Icons.collections_bookmark,
        points: 50,
        type: AchievementType.wordsLearned,
        requirement: {'count': 10},
      ),
      Achievement(
        id: 'word_collector_50',
        title: '词汇大师',
        description: '学习50个单词',
        icon: Icons.auto_stories,
        points: 100,
        type: AchievementType.wordsLearned,
        requirement: {'count': 50},
      ),
      Achievement(
        id: 'word_collector_100',
        title: '词汇专家',
        description: '学习100个单词',
        icon: Icons.menu_book,
        points: 200,
        type: AchievementType.wordsLearned,
        requirement: {'count': 100},
      ),

      // 学习天数成就
      Achievement(
        id: 'first_day',
        title: '第一天',
        description: '学习满1天',
        icon: Icons.today,
        points: 10,
        type: AchievementType.studyDays,
        requirement: {'days': 1},
      ),
      Achievement(
        id: 'week_warrior',
        title: '周常选手',
        description: '学习满7天',
        icon: Icons.view_week,
        points: 100,
        type: AchievementType.studyDays,
        requirement: {'days': 7},
      ),
      Achievement(
        id: 'month_master',
        title: '月度冠军',
        description: '学习满30天',
        icon: Icons.calendar_month,
        points: 300,
        type: AchievementType.studyDays,
        requirement: {'days': 30},
      ),

      // 连续打卡成就
      Achievement(
        id: 'streak_3',
        title: '坚持不懈',
        description: '连续学习3天',
        icon: Icons.local_fire_department,
        points: 50,
        type: AchievementType.streak,
        requirement: {'days': 3},
      ),
      Achievement(
        id: 'streak_7',
        title: '火焰战士',
        description: '连续学习7天',
        icon: Icons.whatshot,
        points: 150,
        type: AchievementType.streak,
        requirement: {'days': 7},
      ),
      Achievement(
        id: 'streak_30',
        title: '传奇之路',
        description: '连续学习30天',
        icon: Icons.emoji_events,
        points: 500,
        type: AchievementType.streak,
        requirement: {'days': 30},
      ),

      // 测验成就
      Achievement(
        id: 'quiz_beginner',
        title: '测验新手',
        description: '完成一次测验',
        icon: Icons.quiz,
        points: 20,
        type: AchievementType.quizScore,
        requirement: {'score': 1},
      ),
      Achievement(
        id: 'quiz_perfect',
        title: '完美表现',
        description: '单次测验100分',
        icon: Icons.stars,
        points: 100,
        type: AchievementType.quizScore,
        requirement: {'score': 100},
      ),

      // 练习时长成就
      Achievement(
        id: 'practice_60',
        title: '勤学苦练',
        description: '累计练习60分钟',
        icon: Icons.access_time,
        points: 50,
        type: AchievementType.practiceTime,
        requirement: {'minutes': 60},
      ),
      Achievement(
        id: 'practice_300',
        title: '学海无涯',
        description: '累计练习5小时',
        icon: Icons.schedule,
        points: 200,
        type: AchievementType.practiceTime,
        requirement: {'minutes': 300},
      ),
      Achievement(
        id: 'practice_1000',
        title: '学霸之路',
        description: '累计练习1000分钟',
        icon: Icons.workspace_premium,
        points: 500,
        type: AchievementType.practiceTime,
        requirement: {'minutes': 1000},
      ),
    ];
  }
}
