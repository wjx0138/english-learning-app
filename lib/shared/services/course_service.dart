import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/course.dart';
import '../../data/models/word.dart';
import '../../data/models/vocabulary_book.dart';

/// 课程数据服务 - 提供预定义的课程列表
class CourseService {
  /// 获取所有课程
  static List<Course> getAllCourses() {
    return [
      // CET-4 课程
      Course(
        id: 'cet4_core',
        name: 'CET-4 核心词汇',
        description: '大学英语四级核心词汇，重点突破',
        theme: CourseTheme.cet4,
        difficulty: CourseDifficulty.intermediate,
        wordIds: [],
        assetPath: 'assets/vocabularies/cet4_ultra.json',
        wordCount: 3849,
        estimatedTime: const Duration(hours: 20),
        tags: ['cet4', '核心', '必考', '考试'],
      ),

      // CET-6 课程
      Course(
        id: 'cet6_core',
        name: 'CET-6 核心词汇',
        description: '大学英语六级核心词汇，提升阅读能力',
        theme: CourseTheme.cet6,
        difficulty: CourseDifficulty.intermediate,
        wordIds: [],
        assetPath: 'assets/vocabularies/cet6_ultra.json',
        wordCount: 5407,
        estimatedTime: const Duration(hours: 25),
        tags: ['cet6', '核心', '进阶', '考试'],
      ),

      // TOEFL 课程
      Course(
        id: 'toefl_core',
        name: 'TOEFL 核心词汇',
        description: '托福考试必备词汇，涵盖听说读写全方位',
        theme: CourseTheme.toefl,
        difficulty: CourseDifficulty.intermediate,
        wordIds: [],
        assetPath: 'assets/vocabularies/toefl_ultra.json',
        wordCount: 6974,
        estimatedTime: const Duration(hours: 35),
        tags: ['toefl', '核心', '出国', '考试'],
      ),

      // IELTS 课程
      Course(
        id: 'ielts_core',
        name: 'IELTS 核心词汇',
        description: '雅思考试核心词汇，适合学术类和培训类考生',
        theme: CourseTheme.ielts,
        difficulty: CourseDifficulty.advanced,
        wordIds: [],
        assetPath: 'assets/vocabularies/ielts_ultra.json',
        wordCount: 5040,
        estimatedTime: const Duration(hours: 30),
        tags: ['ielts', '核心', '留学', '考试'],
      ),

      // GRE 课程
      Course(
        id: 'gre_essential',
        name: 'GRE 核心词汇',
        description: 'GRE必背词汇，涵盖高频考点，冲刺名校必备',
        theme: CourseTheme.gre,
        difficulty: CourseDifficulty.expert,
        wordIds: [],
        assetPath: 'assets/vocabularies/gre_ultra.json',
        wordCount: 7504,
        estimatedTime: const Duration(hours: 50),
        isPremium: true,
        tags: ['gre', '核心', '必备', '考试'],
      ),

      // 考研英语
      Course(
        id: 'kaoyan_core',
        name: '考研英语核心词汇',
        description: '考研英语必备词汇，涵盖历年高频考点',
        theme: CourseTheme.kaoyan,
        difficulty: CourseDifficulty.advanced,
        wordIds: [],
        assetPath: 'assets/vocabularies/kaoyan_complete.json',
        wordCount: 4777,
        estimatedTime: const Duration(hours: 40),
        tags: ['考研', '核心', '必备', '考试'],
      ),

      // 日常英语
      Course(
        id: 'daily_conversation',
        name: '日常会话词汇',
        description: '日常生活高频词汇，提升交流能力',
        theme: CourseTheme.daily,
        difficulty: CourseDifficulty.beginner,
        wordIds: [],
        assetPath: 'assets/vocabularies/daily_complete.json',
        wordCount: 1000,
        estimatedTime: const Duration(hours: 20),
        tags: ['日常', '会话', '高频'],
      ),
    ];
  }

  /// 按主题分组课程
  static List<CourseCategory> getCoursesByCategory() {
    final allCourses = getAllCourses();
    final Map<CourseTheme, List<Course>> grouped = {};

    for (final course in allCourses) {
      if (!grouped.containsKey(course.theme)) {
        grouped[course.theme] = [];
      }
      grouped[course.theme]!.add(course);
    }

    return grouped.entries.map((entry) {
      return CourseCategory(
        theme: entry.key,
        courses: entry.value,
        description: _getCategoryDescription(entry.key),
      );
    }).toList();
  }

  /// 按难度筛选课程
  static List<Course> getCoursesByDifficulty(CourseDifficulty difficulty) {
    return getAllCourses()
        .where((course) => course.difficulty == difficulty)
        .toList();
  }

  /// 获取课程详情
  static Course? getCourseById(String id) {
    try {
      return getAllCourses().firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取推荐课程
  static List<Course> getRecommendedCourses() {
    // 这里可以根据用户的学习记录推荐课程
    // 目前返回热门课程
    return [
      getCourseById('cet4_core')!,
      getCourseById('cet6_core')!,
      getCourseById('toefl_core')!,
      getCourseById('daily_conversation')!,
    ];
  }

  /// 获取新课程
  static List<Course> getNewCourses() {
    return getAllCourses().take(5).toList();
  }

  /// 搜索课程
  static List<Course> searchCourses(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllCourses().where((course) {
      return course.name.toLowerCase().contains(lowerQuery) ||
          course.description.toLowerCase().contains(lowerQuery) ||
          course.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  static String _getCategoryDescription(CourseTheme theme) {
    switch (theme) {
      case CourseTheme.cet4:
        return '大学英语四级考试词汇';
      case CourseTheme.cet6:
        return '大学英语六级考试词汇';
      case CourseTheme.toefl:
        return '托福考试必备词汇';
      case CourseTheme.ielts:
        return '雅思考试核心词汇';
      case CourseTheme.gre:
        return 'GRE考试高分词汇';
      case CourseTheme.kaoyan:
        return '考研英语必备词汇';
      case CourseTheme.business:
        return '商务职场专业词汇';
      case CourseTheme.travel:
        return '旅游出行实用词汇';
      case CourseTheme.daily:
        return '日常生活交流词汇';
      case CourseTheme.academic:
        return '学术研究专业词汇';
      case CourseTheme.technology:
        return '科技前沿相关词汇';
    }
  }

  /// 获取所有可用词库列表（用于词库选择页面）
  static List<VocabularyBook> getAllVocabularyBooks() {
    return [
      VocabularyBook(
        id: 'cet4_001',
        name: 'CET-4 核心词汇',
        description: '大学英语四级核心词汇，覆盖高频考试词汇',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 3849,
        level: 2,
        category: 'exam',
        tags: ['CET4', 'exam', 'college'],
        isDownloaded: true,
        filePath: 'assets/vocabularies/cet4_ultra.json',
      ),
      VocabularyBook(
        id: 'cet6_001',
        name: 'CET-6 核心词汇',
        description: '大学英语六级核心词汇，涵盖高级英语词汇',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 5407,
        level: 3,
        category: 'exam',
        tags: ['CET6', 'exam', 'college', 'advanced'],
        isDownloaded: true,
        filePath: 'assets/vocabularies/cet6_ultra.json',
      ),
      VocabularyBook(
        id: 'toefl_001',
        name: 'TOEFL 核心词汇',
        description: '托福考试必备词汇，涵盖听说读写',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 6974,
        level: 3,
        category: 'exam',
        tags: ['TOEFL', 'exam', 'study_abroad'],
        isDownloaded: true,
        filePath: 'assets/vocabularies/toefl_ultra.json',
      ),
      VocabularyBook(
        id: 'ielts_001',
        name: 'IELTS 核心词汇',
        description: '雅思考试核心词汇，学术类和培训类',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 5040,
        level: 3,
        category: 'exam',
        tags: ['IELTS', 'exam', 'study_abroad'],
        isDownloaded: true,
        filePath: 'assets/vocabularies/ielts_ultra.json',
      ),
      VocabularyBook(
        id: 'gre_001',
        name: 'GRE 核心词汇',
        description: 'GRE考试高分词汇，冲刺名校必备',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 7504,
        level: 4,
        category: 'exam',
        tags: ['GRE', 'exam', 'graduate'],
        isDownloaded: true,
        filePath: 'assets/vocabularies/gre_ultra.json',
      ),
      VocabularyBook(
        id: 'kaoyan_001',
        name: '考研英语核心词汇',
        description: '考研英语必备词汇，历年高频考点',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 4777,
        level: 3,
        category: 'exam',
        tags: ['考研', 'exam', 'graduate'],
        isDownloaded: true,
        filePath: 'assets/vocabularies/kaoyan_complete.json',
      ),
      VocabularyBook(
        id: 'daily_001',
        name: '日常英语词汇',
        description: '日常生活交流词汇，提升沟通能力',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 1000,
        level: 1,
        category: 'daily',
        tags: ['日常', 'daily', 'life'],
        isDownloaded: true,
        filePath: 'assets/vocabularies/daily_complete.json',
      ),
    ];
  }

  /// Load vocabulary words for a specific course
  static Future<List<Word>> loadCourseWords(String courseId) async {
    try {
      // Get the course by ID
      final course = getCourseById(courseId);
      if (course == null) {
        throw Exception('Course not found: $courseId');
      }

      // Check if the course has an asset path
      if (course.assetPath == null) {
        throw Exception('Course does not have an asset path: $courseId');
      }

      // Load words from the course's asset file
      final String jsonString = await rootBundle.loadString(course.assetPath!);
      final dynamic jsonData = json.decode(jsonString);

      // Handle both array format and object with 'words' key format
      List<dynamic> wordsJson;
      if (jsonData is List) {
        // Direct array format: [{word1}, {word2}, ...]
        wordsJson = jsonData;
      } else if (jsonData is Map) {
        // Object format: {"words": [{word1}, {word2}, ...]}
        wordsJson = jsonData['words'] as List<dynamic>;
      } else {
        throw Exception('Invalid JSON format: expected array or object with words key');
      }

      final words = wordsJson
          .map((wordJson) => Word.fromJson(wordJson as Map<String, dynamic>))
          .toList();

      return words;
    } catch (e) {
      throw Exception('Failed to load course words: $e');
    }
  }
}
