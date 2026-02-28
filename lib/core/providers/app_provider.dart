import 'package:flutter/material.dart';
import '../../data/models/word.dart';
import '../../data/models/typing_practice.dart';
import '../../data/models/gamification.dart';
import '../../shared/services/gamification_service.dart';

/// Global application state provider
class AppProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // Vocabulary words
  List<Word> _words = [];

  List<Word> get words => _words;

  Future<void> loadVocabularyWords(List<Word> words) async {
    _words = words;
    notifyListeners();
  }

  // Game data
  UserGameData? _gameData;

  UserGameData? get gameData => _gameData;
  int get level => _gameData?.level ?? 1;
  int get totalPoints => _gameData?.totalPoints ?? 0;
  int get streak => _gameData?.streak ?? 0;
  String get levelTitle => _gameData?.levelTitle ?? '初学者';

  /// 初始化游戏数据
  Future<void> initGameData() async {
    _gameData = await GamificationService.getGameData();
    notifyListeners();
  }

  /// 刷新游戏数据
  Future<void> refreshGameData() async {
    _gameData = await GamificationService.getGameData();
    notifyListeners();
  }

  /// 添加积分
  Future<void> addPoints(int points, {PointEventType? type}) async {
    _gameData = await GamificationService.addPoints(points, type: type);
    notifyListeners();
  }

  /// 记录学习活动
  Future<void> recordStudy({
    int? wordsLearned,
    int? practiceMinutes,
    int? correctAnswers,
    int? quizScore,
  }) async {
    _gameData = await GamificationService.recordStudyActivity(
      wordsLearned: wordsLearned,
      practiceMinutes: practiceMinutes,
      correctAnswers: correctAnswers,
      quizScore: quizScore,
    );
    notifyListeners();
  }

  /// 检查成就
  Future<List<Achievement>> checkAchievements() async {
    final newlyUnlocked = await GamificationService.checkAchievements();
    if (newlyUnlocked.isNotEmpty) {
      await refreshGameData();
    }
    return newlyUnlocked;
  }

  // App statistics (legacy, kept for compatibility)
  int _wordsLearned = 0;
  int _studyStreak = 0;
  Duration _totalStudyTime = Duration.zero;

  int get wordsLearned => _wordsLearned;
  int get studyStreak => _studyStreak;
  Duration get totalStudyTime => _totalStudyTime;

  @Deprecated('Use recordStudy instead')
  void incrementWordsLearned() {
    _wordsLearned++;
    notifyListeners();
  }

  @Deprecated('Use recordStudy instead')
  void incrementStreak() {
    _studyStreak++;
    notifyListeners();
  }

  void addStudyTime(Duration duration) {
    _totalStudyTime = _totalStudyTime + duration;
    notifyListeners();
  }

  // Typing settings
  TypingSettings _typingSettings = const TypingSettings();

  TypingSettings get typingSettings => _typingSettings;

  void updateTypingSettings(TypingSettings settings) {
    _typingSettings = settings;
    notifyListeners();
  }
}
