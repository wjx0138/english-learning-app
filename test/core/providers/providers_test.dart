import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:english_learning_app/core/providers/app_provider.dart';
import 'package:english_learning_app/core/providers/card_provider.dart';
import 'package:english_learning_app/core/providers/progress_provider.dart';
import 'package:english_learning_app/data/models/word.dart';
import 'package:english_learning_app/core/utils/srs_algorithm.dart';

void main() {
  group('AppProvider Tests', () {
    test('Should initialize with default values', () {
      final provider = AppProvider();

      expect(provider.currentIndex, 0);
      expect(provider.words, isEmpty);
      expect(provider.level, 1);
      expect(provider.totalPoints, 0);
      expect(provider.streak, 0);
    });

    test('Should change index correctly', () {
      final provider = AppProvider();

      provider.setIndex(1);
      expect(provider.currentIndex, 1);

      provider.setIndex(2);
      expect(provider.currentIndex, 2);
    });

    test('Should load vocabulary words', () async {
      final provider = AppProvider();

      final words = [
        Word(
          id: 'w1',
          word: 'test1',
          definition: 'n. 测试1',
          examples: const [],
          difficulty: 1,
          tags: const ['basic'],
        ),
        Word(
          id: 'w2',
          word: 'test2',
          definition: 'n. 测试2',
          examples: const [],
          difficulty: 1,
          tags: const ['basic'],
        ),
      ];

      await provider.loadVocabularyWords(words);

      expect(provider.words.length, 2);
      expect(provider.words.first.word, 'test1');
    });

    test('Should notify listeners when words change', () async {
      final provider = AppProvider();
      bool notified = false;

      provider.addListener(() {
        notified = true;
      });

      final words = [
        Word(
          id: 'w1',
          word: 'new',
          definition: 'adj. 新的',
          examples: const [],
          difficulty: 1,
          tags: const ['basic'],
        ),
      ];

      await provider.loadVocabularyWords(words);

      expect(notified, true);
      expect(provider.words.length, 1);
    });
  });

  group('CardProvider Tests', () {
    test('Should initialize with default values', () {
      final provider = CardProvider();

      expect(provider.currentWord, isNull);
      expect(provider.currentCard, isNull);
      expect(provider.cardsStudied, 0);
      expect(provider.correctAnswers, 0);
      expect(provider.wrongAnswers, 0);
      expect(provider.accuracy, 0.0);
      expect(provider.wrongWordIds, isEmpty);
    });

    test('Should load card for study', () {
      final provider = CardProvider();

      final word = Word(
        id: 'word-1',
        word: 'test',
        definition: 'n. 测试',
        examples: const [],
        difficulty: 1,
        tags: const [],
      );

      final card = FSRSCard(
        id: 'card-1',
        wordId: 'word-1',
        state: FSRSAlgorithm.stateNew,
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        createdAt: DateTime.now(),
        nextReview: DateTime.now(),
      );

      provider.loadCard(word, card);

      expect(provider.currentWord?.id, 'word-1');
      expect(provider.currentCard?.id, 'card-1');
    });

    test('Should submit answer correctly', () {
      final provider = CardProvider();

      final word = Word(
        id: 'word-1',
        word: 'test',
        definition: 'n. 测试',
        examples: const [],
        difficulty: 1,
        tags: const [],
      );

      final card = FSRSCard(
        id: 'card-1',
        wordId: 'word-1',
        state: FSRSAlgorithm.stateNew,
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        createdAt: DateTime.now(),
        nextReview: DateTime.now(),
      );

      provider.loadCard(word, card);
      provider.submitAnswer(FSRSAlgorithm.ratingGood);

      expect(provider.cardsStudied, 1);
      expect(provider.correctAnswers, 1);
      expect(provider.wrongAnswers, 0);
      expect(provider.accuracy, 1.0);
    });

    test('Should track wrong answers', () {
      final provider = CardProvider();

      final word = Word(
        id: 'word-1',
        word: 'test',
        definition: 'n. 测试',
        examples: const [],
        difficulty: 1,
        tags: const [],
      );

      final card = FSRSCard(
        id: 'card-1',
        wordId: 'word-1',
        state: FSRSAlgorithm.stateNew,
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        createdAt: DateTime.now(),
        nextReview: DateTime.now(),
      );

      provider.loadCard(word, card);
      provider.submitAnswer(FSRSAlgorithm.ratingAgain);

      expect(provider.correctAnswers, 0);
      expect(provider.wrongAnswers, 1);
      expect(provider.wrongWordIds, contains('word-1'));
    });

    test('Should reset session', () {
      final provider = CardProvider();

      final word = Word(
        id: 'word-1',
        word: 'test',
        definition: 'n. 测试',
        examples: const [],
        difficulty: 1,
        tags: const [],
      );

      final card = FSRSCard(
        id: 'card-1',
        wordId: 'word-1',
        state: FSRSAlgorithm.stateNew,
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        createdAt: DateTime.now(),
        nextReview: DateTime.now(),
      );

      provider.loadCard(word, card);
      provider.submitAnswer(FSRSAlgorithm.ratingGood);

      provider.resetSession();

      expect(provider.currentWord, isNull);
      expect(provider.currentCard, isNull);
      expect(provider.cardsStudied, 0);
      expect(provider.correctAnswers, 0);
      expect(provider.wrongAnswers, 0);
      expect(provider.wrongWordIds, isEmpty);
    });
  });

  group('ProgressProvider Tests', () {
    test('Should initialize with default values', () {
      final provider = ProgressProvider();

      expect(provider.totalCardsStudied, 0);
      expect(provider.totalCorrectAnswers, 0);
      expect(provider.totalWrongAnswers, 0);
      expect(provider.currentStreak, 0);
      expect(provider.dailyGoal, 20);
    });

    test('Should have correct initial accuracy', () {
      final provider = ProgressProvider();

      expect(provider.overallAccuracy, 0.0);
    });

    test('Should track vocabulary size', () {
      final provider = ProgressProvider();

      expect(provider.totalVocabularySize, 100);
    });

    test('Should track learned vocabulary', () {
      final provider = ProgressProvider();

      expect(provider.learnedVocabularyCount, 0);
    });

    test('Should calculate vocabulary progress', () {
      final provider = ProgressProvider();

      final progress = provider.vocabularyProgress;
      expect(progress, greaterThanOrEqualTo(0));
      expect(progress, lessThanOrEqualTo(1));
    });

    test('Should get weekly study data', () {
      final provider = ProgressProvider();

      final weeklyData = provider.weeklyStudyData;
      expect(weeklyData, isA<Map>());
    });

    test('Should get achievements list', () {
      final provider = ProgressProvider();

      final achievements = provider.achievements;
      expect(achievements, isNotEmpty);
    });

    test('Should provide getters for all stats', () {
      final provider = ProgressProvider();

      expect(provider.totalStudyDays, isA<int>());
      expect(provider.longestStreak, isA<int>());
      expect(provider.lastStudyDate, isA<DateTime?>());
    });
  });

  group('Provider Integration Tests', () {
    test('Should work together across providers', () async {
      final appProvider = AppProvider();
      final cardProvider = CardProvider();
      final progressProvider = ProgressProvider();

      // Load vocabulary
      final words = [
        Word(
          id: 'w1',
          word: 'test',
          definition: 'n. 测试',
          examples: const [],
          difficulty: 1,
          tags: const ['basic'],
        ),
      ];

      await appProvider.loadVocabularyWords(words);

      // Create card for word
      final card = FSRSCard(
        id: 'card-1',
        wordId: 'w1',
        state: FSRSAlgorithm.stateNew,
        easeFactor: 2.5,
        interval: 0,
        repetitions: 0,
        createdAt: DateTime.now(),
        nextReview: DateTime.now(),
      );

      cardProvider.loadCard(words.first, card);

      // Verify integration
      expect(appProvider.words.length, 1);
      expect(cardProvider.currentCard?.id, 'card-1');
      expect(progressProvider.totalVocabularySize, 100);
    });

    test('Should handle complete learning session', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});

      final appProvider = AppProvider();
      final cardProvider = CardProvider();
      final progressProvider = ProgressProvider();

      // Create words and cards
      final words = List.generate(
        5,
        (i) => Word(
          id: 'w$i',
          word: 'word$i',
          definition: 'n. 词$i',
          examples: const [],
          difficulty: 1,
          tags: const ['basic'],
        ),
      );

      // Study each card
      for (var i = 0; i < words.length; i++) {
        final card = FSRSCard(
          id: 'card-$i',
          wordId: 'w$i',
          state: FSRSAlgorithm.stateNew,
          easeFactor: 2.5,
          interval: 0,
          repetitions: 0,
          createdAt: DateTime.now(),
          nextReview: DateTime.now(),
        );

        cardProvider.loadCard(words[i], card);

        // Submit answers: 3 correct, 2 wrong
        if (i < 3) {
          cardProvider.submitAnswer(FSRSAlgorithm.ratingGood);
        } else {
          cardProvider.submitAnswer(FSRSAlgorithm.ratingAgain);
        }
      }

      // Record a study session
      await progressProvider.recordStudySession(
        cardsStudied: 5,
        correctAnswers: 3,
        wrongAnswers: 2,
      );

      expect(progressProvider.totalCardsStudied, 5);
      expect(progressProvider.totalCorrectAnswers, 3);
      expect(progressProvider.totalWrongAnswers, 2);
      expect(progressProvider.overallAccuracy, 0.6);
    });

    test('Should track progress across providers', () async {
      final appProvider = AppProvider();
      final progressProvider = ProgressProvider();

      // Load vocabulary
      final words = List.generate(
        10,
        (i) => Word(
          id: 'w$i',
          word: 'word$i',
          definition: 'n. 词$i',
          examples: const [],
          difficulty: 1,
          tags: const ['basic'],
        ),
      );

      await appProvider.loadVocabularyWords(words);

      expect(appProvider.words.length, 10);
      expect(progressProvider.totalVocabularySize, 100);
    });
  });
}
