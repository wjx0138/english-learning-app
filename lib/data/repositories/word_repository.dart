import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../../models/word.dart';

class WordRepository {
  static const String _dbName = 'english_learning.db';
  static const int _dbVersion = 1;

  late Database _database;

  // Singleton pattern
  static final WordRepository _instance = WordRepository._internal();
  factory WordRepository() => _instance;
  WordRepository._internal();

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
    );
  }

  Future<void> _createDb(Database db, int version) async {
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
  }

  /// Load vocabulary from assets
  Future<void> loadVocabularyFromAssets(String jsonPath) async {
    final db = await database;
    final assetBundle = await rootBundle.loadString(jsonPath);
    final words = jsonDecode(assetBundle) as List;

    await db.transaction((txn) async {
      for (final wordData in words) {
        final word = Word.fromJson(wordData);
        await txn.insert('words', word.toJson(), conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  /// Get all words
  Future<List<Word>> getAllWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return List.generate(maps.length, (i) {
      return Word.fromJson(maps[i]);
    });
  }

  /// Get words by tag
  Future<List<Word>> getWordsByTag(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'tags LIKE ?',
      whereArgs: ['%$tag%'],
    );
    return List.generate(maps.length, (i) {
      return Word.fromJson(maps[i]);
    });
  }

  /// Get words by difficulty level
  Future<List<Word>> getWordsByDifficulty(int difficulty) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'difficulty = ?',
      whereArgs: [difficulty],
    );
    return List.generate(maps.length, (i) {
      return Word.fromJson(maps[i]);
    });
  }

  /// Add custom word
  Future<int> addWord(Word word) async {
    final db = await database;
    return await db.insert('words', word.toJson());
  }

  /// Delete word
  Future<int> deleteWord(String id) async {
    final db = await database;
    return await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }
}
