import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/word.dart';

/// 增强的词库加载服务 - 支持多文件和分批加载
class EnhancedVocabularyLoader {
  // 缓存已加载的词汇
  static final Map<String, List<Word>> _vocabularyCache = {};

  // 词库文件配置
  static const Map<String, String> VOCABULARY_FILES = {
    // === 考试词库（小规模） ===
    'cet4': 'assets/vocabularies/cet4.json',
    'cet4_sample': 'assets/vocabularies/cet4_sample.json',
    'cet4_complete': 'assets/vocabularies/cet4_complete.json',
    'cet4_extended': 'assets/vocabularies/cet4_extended.json',
    'cet6': 'assets/vocabularies/cet6.json',
    'cet6_complete': 'assets/vocabularies/cet6_complete.json',
    'toefl_complete': 'assets/vocabularies/toefl_complete.json',
    'ielts_complete': 'assets/vocabularies/ielts_complete.json',

    // === 考试词库（超大规模）⭐ 推荐深入学习 ===
    'cet4_ultra': 'assets/vocabularies/cet4_ultra.json',
    'cet6_ultra': 'assets/vocabularies/cet6_ultra.json',
    'toefl_ultra': 'assets/vocabularies/toefl_ultra.json',
    'ielts_ultra': 'assets/vocabularies/ielts_ultra.json',
    'gre_ultra': 'assets/vocabularies/gre_ultra.json',

    // === 主题词库（小规模） ===
    'daily_life': 'assets/vocabularies/daily_life.json',
    'education': 'assets/vocabularies/education.json',
    'business': 'assets/vocabularies/business.json',
    'technology': 'assets/vocabularies/technology.json',
    'travel': 'assets/vocabularies/travel.json',
    'food': 'assets/vocabularies/food.json',
    'health': 'assets/vocabularies/health.json',
    'nature': 'assets/vocabularies/nature.json',

    // === 主题词库（完整规模）⭐ 推荐专业学习 ===
    'business_complete': 'assets/vocabularies/business_complete.json',
    'technology_complete': 'assets/vocabularies/technology_complete.json',
    'academic_complete': 'assets/vocabularies/academic_complete.json',
    'daily_complete': 'assets/vocabularies/daily_complete.json',
  };

  // 默认词库顺序（使用完整版本）
  static const List<String> DEFAULT_VOCABULARY_ORDER = [
    'cet4',
    'cet6',
    'toefl_complete',
    'ielts_complete',
  ];

  /// 获取所有可用的词库
  static List<String> getAvailableVocabularies() {
    return VOCABULARY_FILES.keys.toList();
  }

  /// 加载单个词库
  static Future<List<Word>> loadVocabulary(String vocabularyName) async {
    // 检查缓存
    if (_vocabularyCache.containsKey(vocabularyName)) {
      return _vocabularyCache[vocabularyName]!;
    }

    // 获取文件路径
    final filePath = VOCABULARY_FILES[vocabularyName];
    if (filePath == null) {
      throw ArgumentError('Unknown vocabulary: $vocabularyName');
    }

    try {
      // 从assets加载
      final jsonString = await rootBundle.loadString(filePath);
      final List<dynamic> jsonList = json.decode(jsonString);

      // 转换为Word对象
      final words = jsonList.map((json) {
        return Word.fromJson(json as Map<String, dynamic>);
      }).toList();

      // 缓存词汇
      _vocabularyCache[vocabularyName] = words;

      print('✅ 已加载词库: $vocabularyName (${words.length} 词)');
      return words;
    } catch (e) {
      print('❌ 加载词库失败: $vocabularyName, 错误: $e');
      // 返回空列表而不是抛出异常
      return [];
    }
  }

  /// 分批加载词库（用于大文件）
  static Future<List<Word>> loadVocabularyBatch(
    String vocabularyName, {
    int offset = 0,
    int limit = 100,
  }) async {
    final allWords = await loadVocabulary(vocabularyName);

    final start = offset;
    final end = (offset + limit).clamp(0, allWords.length);

    return allWords.sublist(start, end);
  }

  /// 加载多个词库并合并
  static Future<List<Word>> loadMultipleVocabularies(
    List<String> vocabularyNames,
  ) async {
    final allWords = <Word>[];

    for (final name in vocabularyNames) {
      final words = await loadVocabulary(name);
      allWords.addAll(words);
    }

    print('✅ 已加载 ${vocabularyNames.length} 个词库，共 ${allWords.length} 词');
    return allWords;
  }

  /// 加载所有可用词库
  static Future<List<Word>> loadAllVocabularies() async {
    return loadMultipleVocabularies(DEFAULT_VOCABULARY_ORDER);
  }

  /// 随机获取指定数量的词汇
  static Future<List<Word>> getRandomWords({
    int count = 20,
    String? vocabularyName,
    int? seed,
  }) async {
    final words = vocabularyName != null
        ? await loadVocabulary(vocabularyName)
        : await loadAllVocabularies();

    if (words.isEmpty) return [];

    // 如果指定了seed，先打乱顺序
    final randomWords = seed != null
        ? List<Word>.from(words)..shuffle(seed)
        : List<Word>.from(words)..shuffle();

    return randomWords.take(count).toList();
  }

  /// 按首字母获取词汇
  static Future<Map<String, List<Word>>> getWordsByAlphabet(
    String vocabularyName,
  ) async {
    final words = await loadVocabulary(vocabularyName);

    final Map<String, List<Word>> alphabetMap = {};

    for (final word in words) {
      final firstLetter = word.word[0].toLowerCase();
      alphabetMap.putIfAbsent(firstLetter, () => []).add(word);
    }

    // 排序每个字母下的单词
    for (final key in alphabetMap.keys) {
      alphabetMap[key]!.sort((a, b) => a.word.compareTo(b.word));
    }

    return alphabetMap;
  }

  /// 按难度获取词汇
  static Future<Map<int, List<Word>>> getWordsByDifficulty(
    String vocabularyName,
  ) async {
    final words = await loadVocabulary(vocabularyName);

    final Map<int, List<Word>> difficultyMap = {};

    for (final word in words) {
      final difficulty = word.difficulty;
      difficultyMap.putIfAbsent(difficulty, () => []).add(word);
    }

    return difficultyMap;
  }

  /// 搜索词汇
  static Future<List<Word>> searchWords(
    String query, {
    String? vocabularyName,
    int limit = 20,
  }) async {
    final words = vocabularyName != null
        ? await loadVocabulary(vocabularyName)
        : await loadAllVocabularies();

    final queryLower = query.toLowerCase();

    final results = words.where((word) {
      return word.word.toLowerCase().contains(queryLower) ||
          (word.definition?.toLowerCase().contains(queryLower) ?? false);
    }).take(limit).toList();

    return results;
  }

  /// 清除缓存
  static void clearCache() {
    _vocabularyCache.clear();
    print('🗑️  词库缓存已清除');
  }

  /// 清除指定词库的缓存
  static void clearCacheFor(String vocabularyName) {
    _vocabularyCache.remove(vocabularyName);
    print('🗑️  已清除词库缓存: $vocabularyName');
  }

  /// 获取缓存统计
  static Map<String, int> getCacheStats() {
    final stats = <String, int>{};

    for (final entry in _vocabularyCache.entries) {
      stats[entry.key] = entry.value.length;
    }

    return stats;
  }

  /// 获取词库统计信息
  static Future<Map<String, dynamic>> getVocabularyStats(
    String vocabularyName,
  ) async {
    try {
      final words = await loadVocabulary(vocabularyName);

      final difficultyCounts = <int, int>{};
      final tagCounts = <String, int>{};

      for (final word in words) {
        // 统计难度
        final difficulty = word.difficulty;
        difficultyCounts[difficulty] = (difficultyCounts[difficulty] ?? 0) + 1;

        // 统计标签
        for (final tag in word.tags) {
          tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
        }
      }

      return {
        'totalWords': words.length,
        'difficultyDistribution': difficultyCounts,
        'tagDistribution': tagCounts,
      };
    } catch (e) {
      return {
        'error': e.toString(),
      };
    }
  }

  /// 保存最后学习的词汇位置
  static Future<void> saveProgress(String vocabularyName, int currentIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vocab_${vocabularyName}_index', currentIndex);
  }

  /// 获取上次学习的词汇位置
  static Future<int?> getProgress(String vocabularyName) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('vocab_${vocabularyName}_index');
  }

  /// 智能词汇推荐 - 基于学习历史推荐词汇
  static Future<List<Word>> getRecommendedWords({
    int count = 10,
    Set<String>? excludeWords,
    int preferredDifficulty = 2,
  }) async {
    final allWords = await loadAllVocabularies();

    // 过滤掉已学习的词汇
    final remainingWords = excludeWords != null
        ? allWords.where((w) => !excludeWords.contains(w.word)).toList()
        : allWords;

    // 优先推荐接近目标难度的词汇
    remainingWords.sort((a, b) {
      final diffA = (a.difficulty - preferredDifficulty).abs();
      final diffB = (b.difficulty - preferredDifficulty).abs();
      return diffA.compareTo(diffB);
    });

    return remainingWords.take(count).toList();
  }

  /// 创建学习计划 - 根据目标生成每日词汇列表
  static Future<List<Word>> generateStudyPlan({
    required String vocabularyName,
    required int dailyTarget,
    required int totalDays,
    int startDay = 1,
  }) async {
    final allWords = await loadVocabulary(vocabularyName);

    // 按难度和重要性排序
    final sortedWords = List<Word>.from(allWords);
    sortedWords.sort((a, b) => a.difficulty.compareTo(b.difficulty));

    final dailyWords = <List<Word>>[];

    for (int day = startDay; day <= totalDays; day++) {
      final startIndex = (day - startDay) * dailyTarget;
      final endIndex = (startIndex + dailyTarget).clamp(0, sortedWords.length);

      if (startIndex < sortedWords.length) {
        dailyWords.add(sortedWords.sublist(startIndex, endIndex));
      }
    }

    // 扁平化为列表（每批用分隔符标记）
    return dailyWords.expand((e) => e).toList();
  }

  /// 导出学习进度报告
  static Future<Map<String, dynamic>> generateProgressReport() async {
    final stats = <String, dynamic>{};

    // 统计所有加载的词库
    for (final vocabName in _vocabularyCache.keys) {
      final words = _vocabularyCache[vocabName]!;
      stats[vocabName] = {
        'totalWords': words.length,
        'difficultyDistribution': <int, int>{},
        'tags': <String>[],
      };

      // 统计难度分布
      for (final word in words) {
        final diff = word.difficulty;
        stats[vocabName]['difficultyDistribution'][diff] =
            (stats[vocabName]['difficultyDistribution'][diff] ?? 0) + 1;
      }

      // 统计标签
      final tagSet = <String>{};
      for (final word in words) {
        tagSet.addAll(word.tags);
      }
      stats[vocabName]['tags'] = tagSet.toList();
    }

    return stats;
  }
}
