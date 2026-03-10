import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../data/models/vocabulary_book.dart';
import '../../data/models/word.dart';

/// Service for importing and managing vocabulary books
class VocabularyService {
  // Vocabulary file paths
  static const String _cet4Path = 'assets/vocabularies/cet4_ultra.json';
  static const String _cet6Path = 'assets/vocabularies/cet6_ultra.json';
  static const String _toeflPath = 'assets/vocabularies/toefl_ultra.json';
  static const String _ieltsPath = 'assets/vocabularies/ielts_ultra.json';
  static const String _grePath = 'assets/vocabularies/gre_ultra.json';
  static const String _kaoyanPath = 'assets/vocabularies/kaoyan_complete.json';
  static const String _dailyPath = 'assets/vocabularies/daily_complete.json';

  List<VocabularyBook> _availableBooks = [];
  List<Word> _loadedWords = [];
  VocabularyBook? _currentBook;

  /// Get list of available vocabulary books
  List<VocabularyBook> get availableBooks => _availableBooks;

  /// Get currently loaded words
  List<Word> get loadedWords => _loadedWords;

  /// Get currently active vocabulary book
  VocabularyBook? get currentBook => _currentBook;

  /// Check if any book is loaded
  bool get hasLoadedBook => _currentBook != null;

  /// Initialize and load available books list
  Future<void> initialize() async {
    _availableBooks = [
      // 考试类词库
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
        filePath: _cet4Path,
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
        filePath: _cet6Path,
      ),
      VocabularyBook(
        id: 'toefl_001',
        name: 'TOEFL 核心词汇',
        description: '托福考试核心词汇，包含学术和日常用语',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 6974,
        level: 4,
        category: 'exam',
        tags: ['TOEFL', 'exam', 'study abroad'],
        isDownloaded: true,
        filePath: _toeflPath,
      ),
      VocabularyBook(
        id: 'ielts_001',
        name: 'IELTS 核心词汇',
        description: '雅思考试核心词汇，覆盖听说读写',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 5040,
        level: 4,
        category: 'exam',
        tags: ['IELTS', 'exam', 'study abroad'],
        isDownloaded: true,
        filePath: _ieltsPath,
      ),
      VocabularyBook(
        id: 'gre_001',
        name: 'GRE 核心词汇',
        description: 'GRE考试核心词汇，涵盖高级学术词汇',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 7504,
        level: 5,
        category: 'exam',
        tags: ['GRE', 'exam', 'graduate', 'advanced'],
        isDownloaded: true,
        filePath: _grePath,
      ),
      VocabularyBook(
        id: 'kaoyan_001',
        name: '考研英语词汇',
        description: '研究生入学考试英语词汇',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 4801,
        level: 3,
        category: 'exam',
        tags: ['考研', 'exam', 'graduate'],
        isDownloaded: true,
        filePath: _kaoyanPath,
      ),
      // 主题类词库
      VocabularyBook(
        id: 'daily_001',
        name: '日常英语词汇',
        description: '日常生活常用词汇，适合初学者',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 1000,
        level: 1,
        category: 'daily',
        tags: ['daily', 'life', 'beginner'],
        isDownloaded: true,
        filePath: _dailyPath,
      ),
    ];
  }

  /// Load vocabulary book from assets
  Future<List<Word>> loadVocabularyBook(VocabularyBook book) async {
    try {
      debugPrint('📂 Loading asset: ${book.filePath}');

      final String jsonString = await rootBundle.loadString(book.filePath!);
      debugPrint('📄 Asset loaded, size: ${jsonString.length} characters');

      final dynamic jsonData = json.decode(jsonString);
      debugPrint('📋 JSON decoded successfully');

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

      debugPrint('🔄 Parsing ${wordsJson.length} words...');

      _loadedWords = wordsJson
          .map((wordJson) => Word.fromJson(wordJson as Map<String, dynamic>))
          .toList();

      _currentBook = book;

      debugPrint('✅ Successfully loaded ${_loadedWords.length} words from ${book.name}');
      return _loadedWords;
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading vocabulary book: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Load CET-4 vocabulary
  Future<List<Word>> loadCET4() async {
    final cet4Book = _availableBooks.firstWhere(
      (book) => book.id == 'cet4_001',
      orElse: () => throw Exception('CET-4 book not found'),
    );
    return loadVocabularyBook(cet4Book);
  }

  /// Load CET-6 vocabulary
  Future<List<Word>> loadCET6() async {
    final cet6Book = _availableBooks.firstWhere(
      (book) => book.id == 'cet6_001',
      orElse: () => throw Exception('CET-6 book not found'),
    );
    return loadVocabularyBook(cet6Book);
  }

  /// Search words by query
  List<Word> searchWords(String query) {
    if (query.isEmpty) return _loadedWords;

    final lowercaseQuery = query.toLowerCase();
    return _loadedWords.where((word) {
      return word.word.toLowerCase().contains(lowercaseQuery) ||
          word.definition.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Get words by difficulty level
  List<Word> getWordsByDifficulty(int minDifficulty, int maxDifficulty) {
    return _loadedWords
        .where((word) =>
            word.difficulty >= minDifficulty &&
            word.difficulty <= maxDifficulty)
        .toList();
  }

  /// Get words by tag
  List<Word> getWordsByTag(String tag) {
    return _loadedWords
        .where((word) => word.tags.contains(tag))
        .toList();
  }

  /// Get random words
  List<Word> getRandomWords(int count) {
    if (_loadedWords.length <= count) {
      return List.from(_loadedWords);
    }

    final shuffled = List<Word>.from(_loadedWords)..shuffle();
    return shuffled.sublist(0, count);
  }

  /// Get word by ID
  Word? getWordById(String id) {
    try {
      return _loadedWords.firstWhere((word) => word.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Clear loaded words
  void clearLoadedWords() {
    _loadedWords = [];
    _currentBook = null;
  }

  /// Get statistics about current vocabulary
  Map<String, dynamic> getVocabularyStats() {
    if (_loadedWords.isEmpty) {
      return {
        'totalWords': 0,
        'averageDifficulty': 0.0,
        'difficultyDistribution': <int, int>{},
      };
    }

    final totalDifficulty = _loadedWords.fold<int>(
      0,
      (sum, word) => sum + word.difficulty,
    );

    final difficultyDistribution = <int, int>{};
    for (final word in _loadedWords) {
      difficultyDistribution[word.difficulty] =
          (difficultyDistribution[word.difficulty] ?? 0) + 1;
    }

    return {
      'totalWords': _loadedWords.length,
      'averageDifficulty': totalDifficulty / _loadedWords.length,
      'difficultyDistribution': difficultyDistribution,
      'currentBook': _currentBook?.name ?? 'None',
    };
  }
}
