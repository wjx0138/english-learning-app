import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../models/word.dart';
import '../../core/utils/srs_algorithm.dart';

class DatabaseHelper {
  static const String _dbName = 'english_learning.db';
  static const int _dbVersion = 1;

  late Database _database;

  // Singleton pattern
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(documentsDirectory.path, _dbName);
    return await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Create words table
    await db.execute('''
      CREATE TABLE words(
        id TEXT PRIMARY KEY,
        word TEXT NOT NULL,
        phonetic TEXT,
        definition TEXT NOT NULL,
        examples TEXT NOT NULL,
        synonyms TEXT,
        antonyms TEXT,
        etymology TEXT,
        difficulty INTEGER NOT NULL,
        tags TEXT NOT NULL
      )
    ''');

    // Create cards table
    await db.execute('''
      CREATE TABLE cards(
        id TEXT PRIMARY KEY,
        word_id TEXT NOT NULL,
        state INTEGER NOT NULL,
        ease_factor REAL NOT NULL,
        interval INTEGER NOT NULL,
        repetitions INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        next_review TEXT NOT NULL,
        last_review TEXT,
        FOREIGN KEY (word_id) REFERENCES words (id) ON DELETE CASCADE
      )
    ''');

    // Create study_sessions table
    await db.execute('''
      CREATE TABLE study_sessions (
        id TEXT PRIMARY KEY,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        total_cards INTEGER NOT NULL,
        correct_cards INTEGER NOT NULL,
        wrong_cards INTEGER NOT NULL,
        wrong_word_ids TEXT
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_cards_next_review ON cards(next_review)');
    await db.execute('CREATE INDEX idx_cards_state ON cards(state)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades
    if (oldVersion < 2) {
      // Add new columns or tables
    }
  }

  // Load vocabulary from assets
  Future<void> loadVocabularyFromAssets(String jsonPath) async {
    final db = await database;
    final assetString = await rootBundle.loadString(jsonPath);
    final words = jsonDecode(assetString) as List;

    await db.transaction((txn) async {
      for (final wordData in words) {
        final word = Word.fromJson(wordData);
        await txn.insert('words', word.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  // Get all words
  Future<List<Word>> getAllWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (i) => Word.fromJson(maps[i]));
  }

  // Get word by ID
  Future<Word?> getWordById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Word.fromJson(maps.first);
  }

  // Get words by tag
  Future<List<Word>> getWordsByTag(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
    );
    return List.generate(maps.length, (i) => Word.fromJson(maps[i]));
  }

  // Get new words (for learning session)
  Future<List<Word>> getNewWords(int limit) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      limit: limit,
      orderBy: 'difficulty ASC',
    );
    return List.generate(maps.length, (i) => Word.fromJson(maps[i]));
  }

  // Save or update card
  Future<void> saveCard(FSRSCard card) async {
    final db = await database;
    await db.insert(
      'cards',
      {
        'id': card.id,
        'word_id': card.wordId,
        'state': card.state,
        'ease_factor': card.easeFactor,
        'interval': card.interval,
        'repetitions': card.repetitions,
        'created_at': card.createdAt.toIso8601String(),
        'next_review': card.nextReview.toIso8601String(),
        'last_review': card.lastReview?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get card by word ID
  Future<FSRSCard?> getCardByWordId(String wordId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'word_id = ?',
      whereArgs: [wordId],
    );

    if (maps.isEmpty) return null;

    final data = maps.first;
    return FSRSCard(
      id: data['id'] as String,
      wordId: data['word_id'] as String,
      state: data['state'] as int,
      easeFactor: data['ease_factor'] as double,
      interval: data['interval'] as int,
      repetitions: data['repetitions'] as int,
      createdAt: DateTime.parse(data['created_at'] as String),
      nextReview: DateTime.parse(data['next_review'] as String),
      lastReview: data['last_review'] != null
          ? DateTime.parse(data['last_review'] as String)
          : null,
    );
  }

  // Get cards due for review
  Future<List<FSRSCard>> getDueCards({int limit = 20}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'cards',
      where: 'next_review <= ?',
      whereArgs: [now],
      orderBy: 'next_review ASC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      final data = maps[i];
      return FSRSCard(
        id: data['id'] as String,
        wordId: data['word_id'] as String,
        state: data['state'] as int,
        easeFactor: data['ease_factor'] as double,
        interval: data['interval'] as int,
        repetitions: data['repetitions'] as int,
        createdAt: DateTime.parse(data['created_at'] as String),
        nextReview: DateTime.parse(data['next_review'] as String),
        lastReview: data['last_review'] != null
            ? DateTime.parse(data['last_review'] as String)
            : null,
      );
    });
  }

  // Save study session
  Future<void> saveStudySession(StudySession session) async {
    final db = await database;
    await db.insert('study_sessions', {
      'id': session.id,
      'started_at': session.startTime.toIso8601String(),
      'completed_at': session.endTime?.toIso8601String(),
      'total_cards': session.totalCards,
      'correct_cards': session.correctCards,
      'wrong_cards': session.wrongCards,
      'wrong_word_ids': jsonEncode(session.wrongWordIds),
    });
  }

  // Get recent study sessions
  Future<List<StudySession>> getRecentStudySessions({int limit = 10}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'study_sessions',
      orderBy: 'started_at DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      final data = maps[i];
      return StudySession(
        id: data['id'] as String,
        startTime: DateTime.parse(data['started_at'] as String),
        endTime: data['completed_at'] != null
            ? DateTime.parse(data['completed_at'] as String)
            : null,
        totalCards: data['total_cards'] as int,
        correctCards: data['correct_cards'] as int,
        wrongCards: data['wrong_cards'] as int,
        wrongWordIds: List<String>.from(
          jsonDecode(data['wrong_word_ids'] as String),
        ),
      );
    });
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

// Study session model
class StudySession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int totalCards;
  final int correctCards;
  final int wrongCards;
  final List<String> wrongWordIds;

  StudySession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.totalCards,
    required this.correctCards,
    required this.wrongCards,
    required this.wrongWordIds,
  });

  StudySession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    int? totalCards,
    int? correctCards,
    int? wrongCards,
    List<String>? wrongWordIds,
  }) {
    return StudySession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalCards: totalCards ?? this.totalCards,
      correctCards: correctCards ?? this.correctCards,
      wrongCards: wrongCards ?? this.wrongCards,
      wrongWordIds: wrongWordIds ?? this.wrongWordIds,
    );
  }

  double get accuracy {
    if (totalCards == 0) return 0.0;
    return correctCards / totalCards;
  }
}
