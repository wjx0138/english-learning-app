import 'package:flutter/material.dart';

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

  // App statistics
  int _wordsLearned = 0;
  int _studyStreak = 0;
  Duration _totalStudyTime = Duration.zero;

  int get wordsLearned => _wordsLearned;
  int get studyStreak => _studyStreak;
  Duration get totalStudyTime => _totalStudyTime;

  void incrementWordsLearned() {
    _wordsLearned++;
    notifyListeners();
  }

  void incrementStreak() {
    _studyStreak++;
    notifyListeners();
  }

  void addStudyTime(Duration duration) {
    _totalStudyTime = _totalStudyTime + duration;
    notifyListeners();
  }
}
