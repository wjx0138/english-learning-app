import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/core/utils/srs_algorithm.dart';

void main() {
  group('FSRSAlgorithm', () {
    group('New Card Tests', () {
      test('Rating Again (1) should move card to Learning state', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateNew,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingAgain,
        );

        expect(result.state, FSRSAlgorithm.stateLearning);
        expect(result.interval, 0);
        expect(result.repetitions, 0);
      });

      test('Rating Hard (2) should move card to Learning state', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateNew,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingHard,
        );

        expect(result.state, FSRSAlgorithm.stateLearning);
        expect(result.interval, 0);
      });

      test('Rating Good (3) should move card to Review state with 1 day interval', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateNew,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingGood,
        );

        expect(result.state, FSRSAlgorithm.stateReview);
        expect(result.interval, 1);
        expect(result.easeFactor, 2.5);
        expect(result.repetitions, 1);
      });

      test('Rating Easy (4) should move card to Review state with 4 day interval', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateNew,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingEasy,
        );

        expect(result.state, FSRSAlgorithm.stateReview);
        expect(result.interval, 4);
        expect(result.easeFactor, 2.6);
        expect(result.repetitions, 1);
      });
    });

    group('Learning Card Tests', () {
      test('Rating Good should graduate to Review state', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateLearning,
          interval: 0,
          repetitions: 0,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingGood,
        );

        expect(result.state, FSRSAlgorithm.stateReview);
        expect(result.interval, 1);
        expect(result.repetitions, 1);
      });

      test('Rating Easy should graduate to Review state with 4 day interval', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateLearning,
          interval: 0,
          repetitions: 0,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingEasy,
        );

        expect(result.state, FSRSAlgorithm.stateReview);
        expect(result.interval, 4);
        expect(result.repetitions, 1);
      });

      test('Rating Again should keep in Learning with 0 interval', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateLearning,
          interval: 0,
          repetitions: 0,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingAgain,
        );

        expect(result.interval, 0);
      });
    });

    group('Review Card Tests', () {
      test('Rating Good should increase interval by ease factor', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateReview,
          interval: 5,
          easeFactor: 2.5,
          repetitions: 1,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingGood,
        );

        expect(result.interval, (5 * 2.5).round()); // 13 days (rounded)
        expect(result.repetitions, 2);
        expect(result.state, FSRSAlgorithm.stateReview);
      });

      test('Rating Easy should increase interval and ease factor', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateReview,
          interval: 5,
          easeFactor: 2.5,
          repetitions: 1,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingEasy,
        );

        expect(result.interval, (5 * 2.5 * 1.3).round()); // ~16 days
        expect(result.easeFactor, 2.65); // 2.5 + 0.15
        expect(result.repetitions, 2);
      });

      test('Rating Hard should slightly increase interval but decrease ease factor', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateReview,
          interval: 10,
          easeFactor: 2.5,
          repetitions: 5,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingHard,
        );

        expect(result.interval, 12); // 10 * 1.2
        expect(result.easeFactor, 2.35); // 2.5 - 0.15
        expect(result.repetitions, 5); // repetitions unchanged
      });

      test('Rating Again should reset to Relearning state', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateReview,
          interval: 10,
          easeFactor: 2.5,
          repetitions: 5,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingAgain,
        );

        expect(result.state, FSRSAlgorithm.stateRelearning);
        expect(result.interval, 0);
        expect(result.repetitions, 0);
      });
    });

    group('Ease Factor Constraints', () {
      test('Ease factor should not go below minimum (1.3)', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateReview,
          interval: 10,
          easeFactor: 1.35,
          repetitions: 1,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingHard,
        );

        expect(result.easeFactor, greaterThanOrEqualTo(FSRSAlgorithm.minimumEaseFactor));
      });

      test('Ease factor should not be reduced below 1.3 after multiple Hard ratings', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateReview,
          interval: 10,
          easeFactor: 1.3,
          repetitions: 1,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingHard,
        );

        expect(result.easeFactor, FSRSAlgorithm.minimumEaseFactor);
      });
    });

    group('Interval Constraints', () {
      test('Interval should not exceed maximum (36500 days)', () {
        final card = FSRSCard(
          id: 'test-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateReview,
          interval: 30000,
          easeFactor: 2.5,
          repetitions: 100,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingEasy,
        );

        expect(result.interval, lessThanOrEqualTo(FSRSAlgorithm.maximumInterval));
      });
    });

    group('Next Review Date Tests', () {
      test('Should calculate next review date correctly', () {
        final baseDate = DateTime(2026, 3, 2);
        final result = FSRSResult(
          state: FSRSAlgorithm.stateReview,
          easeFactor: 2.5,
          interval: 5,
          repetitions: 1,
        );

        final nextReview = FSRSAlgorithm.getNextReviewDate(
          result: result,
          baseDate: baseDate,
        );

        expect(nextReview, DateTime(2026, 3, 7));
      });

      test('Should use current date if baseDate not provided', () {
        final now = DateTime.now();
        final result = FSRSResult(
          state: FSRSAlgorithm.stateReview,
          easeFactor: 2.5,
          interval: 1,
          repetitions: 1,
        );

        final nextReview = FSRSAlgorithm.getNextReviewDate(result: result);

        expect(nextReview.difference(now).inDays, greaterThanOrEqualTo(0));
        expect(nextReview.difference(now).inDays, lessThanOrEqualTo(1));
      });
    });

    group('Due Cards Test', () {
      test('Should return cards due for review', () {
        final now = DateTime(2026, 3, 2, 12, 0);

        final cards = [
          FSRSCard(
            id: 'card-1',
            wordId: 'word-1',
            createdAt: now,
            nextReview: now.subtract(const Duration(days: 1)), // Due
          ),
          FSRSCard(
            id: 'card-2',
            wordId: 'word-2',
            createdAt: now,
            nextReview: now, // Due now
          ),
          FSRSCard(
            id: 'card-3',
            wordId: 'word-3',
            createdAt: now,
            nextReview: now.add(const Duration(days: 1)), // Not due
          ),
        ];

        final dueCards = FSRSAlgorithm.getDueCards(
          allCards: cards,
          currentDate: now,
        );

        expect(dueCards.length, 2);
        expect(dueCards[0].id, 'card-1');
        expect(dueCards[1].id, 'card-2');
      });

      test('Should return empty list if no cards are due', () {
        final now = DateTime(2026, 3, 2, 12, 0);

        final cards = [
          FSRSCard(
            id: 'card-1',
            wordId: 'word-1',
            createdAt: now,
            nextReview: now.add(const Duration(days: 1)),
          ),
          FSRSCard(
            id: 'card-2',
            wordId: 'word-2',
            createdAt: now,
            nextReview: now.add(const Duration(days: 5)),
          ),
        ];

        final dueCards = FSRSAlgorithm.getDueCards(
          allCards: cards,
          currentDate: now,
        );

        expect(dueCards.length, 0);
      });

      test('Should use current date if not provided', () {
        final cards = [
          FSRSCard(
            id: 'card-1',
            wordId: 'word-1',
            createdAt: DateTime.now(),
            nextReview: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ];

        final dueCards = FSRSAlgorithm.getDueCards(allCards: cards);

        expect(dueCards.length, 1);
      });
    });
  });

  group('FSRSCard Model Tests', () {
    test('Should create card with all required fields', () {
      final now = DateTime.now();
      final card = FSRSCard(
        id: 'test-id',
        wordId: 'word-id',
        createdAt: now,
        nextReview: now,
      );

      expect(card.id, 'test-id');
      expect(card.wordId, 'word-id');
      expect(card.state, FSRSAlgorithm.stateNew);
      expect(card.easeFactor, 2.5);
      expect(card.interval, 0);
      expect(card.repetitions, 0);
    });

    test('Should serialize to JSON correctly', () {
      final now = DateTime(2026, 3, 2, 12, 0);
      final card = FSRSCard(
        id: 'test-id',
        wordId: 'word-id',
        state: FSRSAlgorithm.stateReview,
        easeFactor: 2.5,
        interval: 5,
        repetitions: 3,
        createdAt: now,
        nextReview: now,
        lastReview: now,
      );

      final json = card.toJson();

      expect(json['id'], 'test-id');
      expect(json['wordId'], 'word-id');
      expect(json['state'], FSRSAlgorithm.stateReview);
      expect(json['easeFactor'], 2.5);
      expect(json['interval'], 5);
      expect(json['repetitions'], 3);
      expect(json['createdAt'], now.toIso8601String());
      expect(json['nextReview'], now.toIso8601String());
      expect(json['lastReview'], now.toIso8601String());
    });

    test('Should deserialize from JSON correctly', () {
      final now = DateTime(2026, 3, 2, 12, 0);
      final json = {
        'id': 'test-id',
        'wordId': 'word-id',
        'state': FSRSAlgorithm.stateReview,
        'easeFactor': 2.5,
        'interval': 5,
        'repetitions': 3,
        'createdAt': now.toIso8601String(),
        'nextReview': now.toIso8601String(),
        'lastReview': now.toIso8601String(),
      };

      final card = FSRSCard.fromJson(json);

      expect(card.id, 'test-id');
      expect(card.wordId, 'word-id');
      expect(card.state, FSRSAlgorithm.stateReview);
      expect(card.easeFactor, 2.5);
      expect(card.interval, 5);
      expect(card.repetitions, 3);
      expect(card.createdAt, now);
      expect(card.nextReview, now);
      expect(card.lastReview, now);
    });

    test('Should create copy with updated fields', () {
      final now = DateTime.now();
      final card = FSRSCard(
        id: 'test-id',
        wordId: 'word-id',
        createdAt: now,
        nextReview: now,
      );

      final updatedCard = card.copyWith(
        state: FSRSAlgorithm.stateReview,
        interval: 5,
      );

      expect(updatedCard.id, 'test-id');
      expect(updatedCard.state, FSRSAlgorithm.stateReview);
      expect(updatedCard.interval, 5);
      expect(updatedCard.wordId, 'word-id');
    });
  });
}
