import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/vocabulary_book.dart';
import '../../data/models/word.dart';

/// Service for importing and managing vocabulary books
class VocabularyService {
  static const String _cet4Path = 'assets/vocabularies/cet4_ultra.json';
  static const String _cet6Path = 'assets/vocabularies/cet6_ultra.json';

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
      VocabularyBook(
        id: 'cet4_001',
        name: 'CET-4 核心词汇',
        description: '大学英语四级核心词汇，覆盖高频考试词汇',
        language: 'en-US',
        targetLanguage: 'zh-CN',
        wordCount: 50,
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
        wordCount: 50,
        level: 3,
        category: 'exam',
        tags: ['CET6', 'exam', 'college', 'advanced'],
        isDownloaded: true,
        filePath: _cet6Path,
      ),
    ];
  }

  /// Load vocabulary book from assets
  Future<List<Word>> loadVocabularyBook(VocabularyBook book) async {
    try {
      final String jsonString = await rootBundle.loadString(book.filePath!);
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

      _loadedWords = wordsJson
          .map((wordJson) => Word.fromJson(wordJson as Map<String, dynamic>))
          .toList();

      _currentBook = book;

      // print('✅ Loaded ${_loadedWords.length} words from ${book.name}');
      return _loadedWords;
    } catch (e) {
      // print('❌ Error loading vocabulary book: $e');
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
