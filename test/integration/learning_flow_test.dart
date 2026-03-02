import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/core/utils/srs_algorithm.dart';
import 'package:english_learning_app/data/models/word.dart';
import 'package:english_learning_app/shared/services/enhanced_vocabulary_loader.dart';

void main() {
  // Initialize Flutter test bindings
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Vocabulary Learning Flow Integration Tests', () {
    group('Complete Learning Workflow', () {
      test('Should load vocabulary and create cards', () async {
        // Step 1: Load vocabulary
        final words = await EnhancedVocabularyLoader.loadVocabulary('cet4_sample');

        expect(words, isNotEmpty);
        expect(words.first, isA<Word>());
      });

      test('Should create FSRS card for word', () {
        // Step 2: Create card for learning
        final card = FSRSCard(
          id: 'card-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateNew,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        expect(card.state, FSRSAlgorithm.stateNew);
        expect(card.repetitions, 0);
      });

      test('Should process card through learning cycle', () {
        // Step 3: Simulate learning cycle
        final card = FSRSCard(
          id: 'card-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateNew,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        // First review - Good rating
        final result1 = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingGood,
        );

        expect(result1.state, FSRSAlgorithm.stateReview);
        expect(result1.repetitions, 1);
        expect(result1.interval, 1);
        expect(result1.easeFactor, 2.5);

        // Update card
        final updatedCard = card.copyWith(
          state: result1.state,
          easeFactor: result1.easeFactor,
          interval: result1.interval,
          repetitions: result1.repetitions,
        );

        // Second review - Good rating
        final result2 = FSRSAlgorithm.calculateNextReview(
          card: updatedCard,
          rating: FSRSAlgorithm.ratingGood,
        );

        expect(result2.repetitions, 2);
        // interval = 1 * 2.5 = 2.5, rounded to 3
        expect(result2.interval, 3);
      });
    });

    group('Card Progression Integration', () {
      test('Should track card from new to mastered', () {
        final now = DateTime.now();
        var card = FSRSCard(
          id: 'card-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateNew,
          createdAt: now,
          nextReview: now,
        );

        // Simulate multiple successful reviews
        final ratings = [
          FSRSAlgorithm.ratingGood, // Day 1
          FSRSAlgorithm.ratingGood, // Day 2
          FSRSAlgorithm.ratingGood, // Day 3-4
          FSRSAlgorithm.ratingGood, // Day 5-7
          FSRSAlgorithm.ratingEasy,  // Bonus
        ];

        for (final rating in ratings) {
          final result = FSRSAlgorithm.calculateNextReview(
            card: card,
            rating: rating,
          );

          card = card.copyWith(
            state: result.state,
            easeFactor: result.easeFactor,
            interval: result.interval,
            repetitions: result.repetitions,
          );

          print('After rating $rating: state=${result.state}, interval=${result.interval}, reps=${result.repetitions}');
        }

        // Verify progression
        expect(card.repetitions, greaterThan(1));
        expect(card.interval, greaterThan(1));
        expect(card.state, FSRSAlgorithm.stateReview);
      });

      test('Should handle forgotten card correctly', () {
        final now = DateTime.now();
        var card = FSRSCard(
          id: 'card-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateReview,
          interval: 10,
          repetitions: 5,
          createdAt: now,
          nextReview: now,
        );

        // User forgets the card
        final result = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingAgain,
        );

        expect(result.state, FSRSAlgorithm.stateRelearning);
        expect(result.interval, 0);
        expect(result.repetitions, 0);
      });
    });

    group('Word Serialization Integration', () {
      test('Should serialize and deserialize word correctly', () {
        final originalWord = Word(
          id: 'word-1',
          word: 'test',
          phonetic: '/test/',
          definition: 'n. 测试',
          examples: ['Test 1', 'Test 2'],
          synonyms: ['exam'],
          antonyms: ['no-test'],
          etymology: 'From Latin',
          difficulty: 1,
          tags: ['basic'],
        );

        // Serialize
        final json = originalWord.toJson();

        // Deserialize
        final deserializedWord = Word.fromJson(json);

        // Verify
        expect(deserializedWord.id, originalWord.id);
        expect(deserializedWord.word, originalWord.word);
        expect(deserializedWord.definition, originalWord.definition);
        expect(deserializedWord.examples.length, originalWord.examples.length);
      });

      test('Should handle batch serialization', () {
        final words = [
          Word(
            id: 'w1',
            word: 'word1',
            definition: 'n. 词汇1',
            examples: [],
            difficulty: 1,
            tags: [],
          ),
          Word(
            id: 'w2',
            word: 'word2',
            definition: 'n. 词汇2',
            examples: [],
            difficulty: 2,
            tags: [],
          ),
        ];

        // Serialize all
        final jsonList = words.map((w) => w.toJson()).toList();

        // Deserialize all
        final deserializedWords = jsonList
            .map((json) => Word.fromJson(json as Map<String, dynamic>))
            .toList();

        expect(deserializedWords.length, 2);
        expect(deserializedWords[0].word, 'word1');
        expect(deserializedWords[1].word, 'word2');
      });
    });

    group('Multiple Cards Scheduling', () {
      test('Should schedule multiple cards correctly', () {
        final now = DateTime.now();
        final cards = [
          FSRSCard(
            id: 'card-1',
            wordId: 'word-1',
            state: FSRSAlgorithm.stateReview,
            interval: 1,
            createdAt: now,
            nextReview: now.add(const Duration(days: 1)),
          ),
          FSRSCard(
            id: 'card-2',
            wordId: 'word-2',
            state: FSRSAlgorithm.stateReview,
            interval: 5,
            createdAt: now,
            nextReview: now.add(const Duration(days: 5)),
          ),
          FSRSCard(
            id: 'card-3',
            wordId: 'word-3',
            state: FSRSAlgorithm.stateReview,
            interval: 10,
            createdAt: now,
            nextReview: now.add(const Duration(days: 10)),
          ),
        ];

        // Get due cards for today
        final dueCards = FSRSAlgorithm.getDueCards(
          allCards: cards,
          currentDate: now.add(const Duration(days: 2)),
        );

        // Should have 1 card due (card-1)
        expect(dueCards.length, 1);
        expect(dueCards.first.id, 'card-1');
      });

      test('Should handle empty due cards list', () {
        final now = DateTime.now();
        final cards = [
          FSRSCard(
            id: 'card-1',
            wordId: 'word-1',
            state: FSRSAlgorithm.stateReview,
            interval: 10,
            createdAt: now,
            nextReview: now.add(const Duration(days: 10)),
          ),
        ];

        final dueCards = FSRSAlgorithm.getDueCards(
          allCards: cards,
          currentDate: now,
        );

        expect(dueCards, isEmpty);
      });
    });

    group('Algorithm Consistency', () {
      test('Should produce consistent results', () {
        final card = FSRSCard(
          id: 'card-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateReview,
          interval: 5,
          easeFactor: 2.5,
          repetitions: 3,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        // Calculate twice with same rating
        final result1 = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingGood,
        );

        final result2 = FSRSAlgorithm.calculateNextReview(
          card: card,
          rating: FSRSAlgorithm.ratingGood,
        );

        // Should be identical
        expect(result1.interval, result2.interval);
        expect(result1.easeFactor, result2.easeFactor);
        expect(result1.repetitions, result2.repetitions);
      });

      test('Should handle all rating types', () {
        final card = FSRSCard(
          id: 'card-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateReview,
          interval: 5,
          easeFactor: 2.5,
          repetitions: 3,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        final ratings = [
          FSRSAlgorithm.ratingAgain,
          FSRSAlgorithm.ratingHard,
          FSRSAlgorithm.ratingGood,
          FSRSAlgorithm.ratingEasy,
        ];

        for (final rating in ratings) {
          final result = FSRSAlgorithm.calculateNextReview(
            card: card,
            rating: rating,
          );

          expect(result.state, isA<int>());
          expect(result.interval, greaterThanOrEqualTo(0));
          expect(result.easeFactor, greaterThanOrEqualTo(1.3));
        }
      });
    });

    group('Data Persistence Flow', () {
      test('Should maintain data integrity through updates', () {
        // Simulate learning session
        var card = FSRSCard(
          id: 'card-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateNew,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        // Simulate multiple reviews
        for (int i = 0; i < 5; i++) {
          final result = FSRSAlgorithm.calculateNextReview(
            card: card,
            rating: FSRSAlgorithm.ratingGood,
          );

          card = card.copyWith(
            state: result.state,
            easeFactor: result.easeFactor,
            interval: result.interval,
            repetitions: result.repetitions,
          );
        }

        // Verify card evolved correctly
        expect(card.repetitions, 5);
        expect(card.interval, greaterThan(0));
        // easeFactor may increase or stay same depending on calculations
        expect(card.easeFactor, greaterThanOrEqualTo(2.5));
      });
    });

    group('Error Handling Integration', () {
      test('Should handle empty word list gracefully', () async {
        final words = await EnhancedVocabularyLoader.getRandomWords(count: 0);

        expect(words, isEmpty);
      });

      test('Should handle invalid ratings', () {
        final card = FSRSCard(
          id: 'card-1',
          wordId: 'word-1',
          state: FSRSAlgorithm.stateNew,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        // Test boundary conditions
        final validResults = [
          FSRSAlgorithm.calculateNextReview(card: card, rating: 1),
          FSRSAlgorithm.calculateNextReview(card: card, rating: 4),
        ];

        for (final result in validResults) {
          expect(result.state, greaterThanOrEqualTo(0));
          expect(result.state, lessThanOrEqualTo(3));
        }
      });
    });
  });
}
