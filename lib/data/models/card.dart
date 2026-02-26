import '../repositories/word_repository.dart';
import '../models/word.dart';
import '../../core/utils/srs_algorithm.dart';

class CardRepository {
  final WordRepository _wordRepository = WordRepository();

  /// Get cards due for review
  Future<List<FSRSCard>> getDueCards() async {
    // TODO: Implement database query for due cards
    return [];
  }

  /// Update card after review
  Future<void> updateCard({
    required FSRSCard card,
    required int rating,
  }) async {
    final result = FSRSAlgorithm.calculateNextReview(
      card: card,
      rating: rating,
    );

    final updatedCard = card.copyWith(
      state: result.state,
      easeFactor: result.easeFactor,
      interval: result.interval,
      repetitions: result.repetitions,
      lastReview: DateTime.now(),
      nextReview: FSRSAlgorithm.getNextReviewDate(result: result),
    );

    // TODO: Save to database
  }

  /// Create new card for a word
  Future<FSRSCard> createCard(String wordId) async {
    return FSRSCard(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      wordId: wordId,
      state: FSRSAlgorithm.stateNew,
      easeFactor: 2.5,
      interval: 0,
      repetitions: 0,
      createdAt: DateTime.now(),
      nextReview: DateTime.now(),
    );
  }
}
