import 'package:flutter/material.dart';

/// 课程数据模型

/// 课程难度
enum CourseDifficulty {
  beginner(1, '初级', '适合英语初学者'),
  intermediate(2, '中级', '有一定英语基础'),
  advanced(3, '高级', '英语水平较好'),
  expert(4, '专业', '专业英语学习'),
  exam(5, '考试', '备考专用');

  final int level;
  final String label;
  final String description;

  const CourseDifficulty(this.level, this.label, this.description);
}

/// 课程主题
enum CourseTheme {
  cet4('CET-4', '大学英语四级', Icons.school),
  cet6('CET-6', '大学英语六级', Icons.school),
  toefl('TOEFL', '托福', Icons.public),
  ielts('IELTS', '雅思', Icons.language),
  gre('GRE', 'GRE', Icons.menu_book),
  kaoyan('考研', '考研英语', Icons.menu_book),
  business('商务', '商务英语', Icons.business_center),
  travel('旅游', '旅游��语', Icons.flight_takeoff),
  daily('日常', '日常英语', Icons.chat),
  academic('学术', '学术英语', Icons.science),
  technology('科技', '科技英语', Icons.computer);

  final String code;
  final String label;
  final IconData icon;

  const CourseTheme(this.code, this.label, this.icon);
}

/// 课程进度
class CourseProgress {
  final String courseId;
  final int totalWords;
  final int learnedWords;
  final int masteredWords;
  final DateTime? lastStudyTime;
  final int studyDays;

  CourseProgress({
    required this.courseId,
    required this.totalWords,
    this.learnedWords = 0,
    this.masteredWords = 0,
    this.lastStudyTime,
    this.studyDays = 0,
  });

  /// 学习进度百分比
  double get progressPercent {
    if (totalWords == 0) return 0.0;
    return learnedWords / totalWords;
  }

  /// 掌握率
  double get masteryRate {
    if (learnedWords == 0) return 0.0;
    return masteredWords / learnedWords;
  }

  /// 是否已开始
  bool get hasStarted => learnedWords > 0;

  /// 是否已完成
  bool get isCompleted => learnedWords >= totalWords;

  CourseProgress copyWith({
    String? courseId,
    int? totalWords,
    int? learnedWords,
    int? masteredWords,
    DateTime? lastStudyTime,
    int? studyDays,
  }) {
    return CourseProgress(
      courseId: courseId ?? this.courseId,
      totalWords: totalWords ?? this.totalWords,
      learnedWords: learnedWords ?? this.learnedWords,
      masteredWords: masteredWords ?? this.masteredWords,
      lastStudyTime: lastStudyTime ?? this.lastStudyTime,
      studyDays: studyDays ?? this.studyDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'totalWords': totalWords,
      'learnedWords': learnedWords,
      'masteredWords': masteredWords,
      'lastStudyTime': lastStudyTime?.toIso8601String(),
      'studyDays': studyDays,
    };
  }

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      courseId: json['courseId'] as String,
      totalWords: json['totalWords'] as int,
      learnedWords: json['learnedWords'] as int? ?? 0,
      masteredWords: json['masteredWords'] as int? ?? 0,
      lastStudyTime: json['lastStudyTime'] != null
          ? DateTime.parse(json['lastStudyTime'] as String)
          : null,
      studyDays: json['studyDays'] as int? ?? 0,
    );
  }
}

/// 课程
class Course {
  final String id;
  final String name;
  final String description;
  final CourseTheme theme;
  final CourseDifficulty difficulty;
  final List<String> wordIds;
  final String? assetPath;  // 词库文件路径
  final int wordCount;
  final Duration estimatedTime;  // 预计学习时间
  final bool isPremium;  // 是否为高级课程
  final List<String> tags;

  Course({
    required this.id,
    required this.name,
    required this.description,
    required this.theme,
    required this.difficulty,
    required this.wordIds,
    this.assetPath,
    this.wordCount = 0,
    this.estimatedTime = const Duration(hours: 10),
    this.isPremium = false,
    this.tags = const [],
  });

  /// 获取课程的难度颜色
  String getDifficultyColor(BuildContext context) {
    switch (difficulty.level) {
      case 1:
        return Colors.green.shade700.toString();
      case 2:
        return Colors.lightGreen.shade700.toString();
      case 3:
        return Colors.orange.shade700.toString();
      case 4:
        return Colors.red.shade700.toString();
      case 5:
        return Colors.purple.shade700.toString();
      default:
        return Colors.grey.shade700.toString();
    }
  }

  Course copyWith({
    String? id,
    String? name,
    String? description,
    CourseTheme? theme,
    CourseDifficulty? difficulty,
    List<String>? wordIds,
    String? assetPath,
    int? wordCount,
    Duration? estimatedTime,
    bool? isPremium,
    List<String>? tags,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      theme: theme ?? this.theme,
      difficulty: difficulty ?? this.difficulty,
      wordIds: wordIds ?? this.wordIds,
      assetPath: assetPath ?? this.assetPath,
      wordCount: wordCount ?? this.wordCount,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      isPremium: isPremium ?? this.isPremium,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'theme': theme.name,
      'difficulty': difficulty.name,
      'wordIds': wordIds,
      'assetPath': assetPath,
      'wordCount': wordCount,
      'estimatedTime': estimatedTime.inMinutes,
      'isPremium': isPremium,
      'tags': tags,
    };
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      theme: CourseTheme.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => CourseTheme.daily,
      ),
      difficulty: CourseDifficulty.values.firstWhere(
        (e) => e.name == json['difficulty'],
        orElse: () => CourseDifficulty.beginner,
      ),
      wordIds: (json['wordIds'] as List<dynamic>).cast<String>(),
      assetPath: json['assetPath'] as String?,
      wordCount: json['wordCount'] as int? ?? 0,
      estimatedTime: Duration(
        minutes: json['estimatedTime'] as int? ?? 600,
      ),
      isPremium: json['isPremium'] as bool? ?? false,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );
  }
}

/// 课程分类
class CourseCategory {
  final CourseTheme theme;
  final List<Course> courses;
  final String description;

  CourseCategory({
    required this.theme,
    required this.courses,
    required this.description,
  });

  /// 获取该分类下的课程数量
  int get courseCount => courses.length;

  /// 获取总词汇量
  int get totalWords =>
      courses.fold(0, (sum, course) => sum + course.wordCount);
}
