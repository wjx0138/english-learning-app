import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/word.dart';
import '../../../core/utils/srs_algorithm.dart';

/// Card learning state provider
class CardProvider extends ChangeNotifier {
  // Current word being studied
  Word? _currentWord;
  Word? get currentWord => _currentWord;

  // Current card being studied
  FSRSCard? _currentCard;
  FSRSCard? get currentCard => _currentCard;

  // Learning statistics
  int _cardsStudied = 0;
  int get cardsStudied => _cardsStudied;

  int _correctAnswers = 0;
  int get correctAnswers => _correctAnswers;

  int _wrongAnswers = 0;
  int get wrongAnswers => _wrongAnswers;

  // Session statistics
  final List<String> _wrongWordIds = [];
  List<String> get wrongWordIds => List.unmodifiable(_wrongWordIds);

  /// Load a card for study
  void loadCard(Word word, FSRSCard card) {
    _currentWord = word;
    _currentCard = card;
    notifyListeners();
  }

  /// Submit answer for current card
  void submitAnswer(int rating) {
    if (_currentCard == null) return;

    // Calculate next review using FSRS
    final result = FSRSAlgorithm.calculateNextReview(
      card: _currentCard!,
      rating: rating,
    );

    // Update card
    _currentCard = _currentCard!.copyWith(
      state: result.state,
      easeFactor: result.easeFactor,
      interval: result.interval,
      repetitions: result.repetitions,
      lastReview: DateTime.now(),
      nextReview: FSRSAlgorithm.getNextReviewDate(result: result),
    );

    // Update statistics
    _cardsStudied++;

    if (rating == FSRSAlgorithm.ratingAgain) {
      _wrongAnswers++;
      if (_currentWord != null) {
        _wrongWordIds.add(_currentWord!.id);
      }
    } else {
      _correctAnswers++;
    }

    notifyListeners();
  }

  /// Get accuracy rate
  double get accuracy {
    if (_cardsStudied == 0) return 0.0;
    return _correctAnswers / _cardsStudied;
  }

  /// Reset current session
  void resetSession() {
    _currentWord = null;
    _currentCard = null;
    _cardsStudied = 0;
    _correctAnswers = 0;
    _wrongAnswers = 0;
    _wrongWordIds.clear();
    notifyListeners();
  }
}
