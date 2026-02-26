/// FSRS (Free Spaced Repetition Scheduler) Algorithm Implementation
/// Based on: https://github.com/open-spaced-repetition/fsrs4anki
///
/// FSRS is a modern spaced repetition algorithm that uses machine learning
/// to optimize review scheduling, replacing the traditional SuperMemo 2 algorithm.

import 'dart:math';

class FSRSAlgorithm {
  // FSRS parameters (default values)
  static const double defaultRequestRetention = 0.9;
  static const int maximumInterval = 36500; // ~100 years
  static const double minimumEaseFactor = 1.3;

  // Card states
  static const int stateNew = 0;
  static const int stateLearning = 1;
  static const int stateReview = 2;
  static const int stateRelearning = 3;

  // Rating values
  static const int ratingAgain = 1;
  static const int ratingHard = 2;
  static const int ratingGood = 3;
  static const int ratingEasy = 4;

  /// Calculate next review parameters based on current state and rating
  static FSRSResult calculateNextReview({
    required FSRSCard card,
    required int rating,
  }) {
    // Copy current card state
    FSRSResult result = FSRSResult(
      state: card.state,
      easeFactor: card.easeFactor,
      interval: card.interval,
      repetitions: card.repetitions,
    );

    switch (card.state) {
      case stateNew:
        _handleNewCard(result, rating);
        break;
      case stateLearning:
      case stateRelearning:
        _handleLearningCard(result, rating);
        break;
      case stateReview:
        _handleReviewCard(result, rating);
        break;
    }

    // Clamp ease factor
    result.easeFactor = max(minimumEaseFactor, result.easeFactor);

    // Clamp interval
    result.interval = min(maximumInterval, result.interval);

    return result;
  }

  static void _handleNewCard(FSRSResult result, int rating) {
    switch (rating) {
      case ratingAgain:
        result.state = stateLearning;
        result.interval = 0; // Same day
        break;
      case ratingHard:
        result.state = stateLearning;
        result.interval = 0;
        break;
      case ratingGood:
        result.state = stateReview;
        result.interval = 1;
        result.easeFactor = 2.5;
        result.repetitions = 1;
        break;
      case ratingEasy:
        result.state = stateReview;
        result.interval = 4;
        result.easeFactor = 2.6;
        result.repetitions = 1;
        break;
    }
  }

  static void _handleLearningCard(FSRSResult result, int rating) {
    switch (rating) {
      case ratingAgain:
        result.interval = 0; // Same day
        break;
      case ratingHard:
        result.interval = 0;
        break;
      case ratingGood:
        result.state = stateReview;
        result.interval = 1;
        result.repetitions += 1;
        break;
      case ratingEasy:
        result.state = stateReview;
        result.interval = 4;
        result.repetitions += 1;
        break;
    }
  }

  static void _handleReviewCard(FSRSResult result, int rating) {
    switch (rating) {
      case ratingAgain:
        result.state = stateRelearning;
        result.interval = 0;
        result.repetitions = 0;
        break;
      case ratingHard:
        result.interval = (result.interval * 1.2).round();
        result.easeFactor -= 0.15;
        break;
      case ratingGood:
        result.interval = (result.interval * result.easeFactor).round();
        result.repetitions += 1;
        break;
      case ratingEasy:
        result.interval = (result.interval * result.easeFactor * 1.3).round();
        result.easeFactor += 0.15;
        result.repetitions += 1;
        break;
    }
  }

  /// Calculate next review date from now
  static DateTime getNextReviewDate({
    required FSRSResult result,
    DateTime? baseDate,
  }) {
    baseDate ??= DateTime.now();
    return baseDate.add(Duration(days: result.interval));
  }

  /// Get cards due for review
  static List<FSRSCard> getDueCards({
    required List<FSRSCard> allCards,
    DateTime? currentDate,
  }) {
    final now = currentDate ?? DateTime.now();
    return allCards.where((card) {
      return card.nextReview.isBefore(now) ||
          card.nextReview.isAtSameMomentAs(now);
    }).toList();
  }
}

/// FSRS Card data model
class FSRSCard {
  final String id;
  final String wordId;
  final int state; // 0=New, 1=Learning, 2=Review, 3=Relearning
  final double easeFactor; // Difficulty factor (1.3 - infinity)
  final int interval; // Days until next review
  final int repetitions; // Number of successful reviews
  final DateTime createdAt;
  final DateTime nextReview;
  final DateTime? lastReview;

  FSRSCard({
    required this.id,
    required this.wordId,
    this.state = FSRSAlgorithm.stateNew,
    this.easeFactor = 2.5,
    this.interval = 0,
    this.repetitions = 0,
    required this.createdAt,
    required this.nextReview,
    this.lastReview,
  });

  FSRSCard copyWith({
    String? id,
    String? wordId,
    int? state,
    double? easeFactor,
    int? interval,
    int? repetitions,
    DateTime? createdAt,
    DateTime? nextReview,
    DateTime? lastReview,
  }) {
    return FSRSCard(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      state: state ?? this.state,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      repetitions: repetitions ?? this.repetitions,
      createdAt: createdAt ?? this.createdAt,
      nextReview: nextReview ?? this.nextReview,
      lastReview: lastReview ?? this.lastReview,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wordId': wordId,
      'state': state,
      'easeFactor': easeFactor,
      'interval': interval,
      'repetitions': repetitions,
      'createdAt': createdAt.toIso8601String(),
      'nextReview': nextReview.toIso8601String(),
      'lastReview': lastReview?.toIso8601String(),
    };
  }

  factory FSRSCard.fromJson(Map<String, dynamic> json) {
    return FSRSCard(
      id: json['id'] as String,
      wordId: json['wordId'] as String,
      state: json['state'] as int,
      easeFactor: json['easeFactor'] as double,
      interval: json['interval'] as int,
      repetitions: json['repetitions'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      nextReview: DateTime.parse(json['nextReview'] as String),
      lastReview: json['lastReview'] != null
          ? DateTime.parse(json['lastReview'] as String)
          : null,
    );
  }
}

/// FSRS calculation result
class FSRSResult {
  int state;
  double easeFactor;
  int interval;
  int repetitions;

  FSRSResult({
    required this.state,
    required this.easeFactor,
    required this.interval,
    required this.repetitions,
  });
}
