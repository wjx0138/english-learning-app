import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../data/models/word.dart';
import '../../data/models/quiz.dart';

/// Service for generating quiz questions
class QuizGeneratorService {
  static final Random _random = Random.secure();
  static final Uuid _uuid = const Uuid();

  /// Generate a quiz session with questions
  static QuizSession generateQuizSession({
    required List<Word> words,
    required QuizMode mode,
    int questionCount = 20,
    List<QuizQuestionType>? questionTypes,
  }) {
    // Shuffle words and take requested count
    final shuffledWords = List<Word>.from(words)..shuffle();
    final selectedWords = shuffledWords.take(questionCount).toList();

    // Generate questions
    final questions = <QuizQuestion>[];
    for (int i = 0; i < selectedWords.length; i++) {
      final word = selectedWords[i];
      final otherWords = selectedWords.where((w) => w.id != word.id).toList();

      // Determine question type
      final type = questionTypes?[_random.nextInt(questionTypes.length)] ??
          QuizQuestionType.values[_random.nextInt(
            QuizQuestionType.values.length - 1, // Exclude fillBlank for now
          )];

      final question = _generateQuestion(
        word: word,
        otherWords: otherWords,
        type: type,
        index: i,
      );

      if (question != null) {
        questions.add(question);
      }
    }

    return QuizSession(
      id: _uuid.v4(),
      startTime: DateTime.now(),
      questions: questions,
      answers: [],
      mode: mode,
    );
  }

  /// Generate a single quiz question
  static QuizQuestion? _generateQuestion({
    required Word word,
    required List<Word> otherWords,
    required QuizQuestionType type,
    required int index,
  }) {
    if (otherWords.length < 3) {
      // Not enough words to generate options
      return null;
    }

    // Generate distractors (wrong options)
    final distractors = List<Word>.from(otherWords);
    distractors.shuffle();
    final selectedDistractors = distractors.take(3).toList();

    QuizQuestion? question;

    switch (type) {
      case QuizQuestionType.definition:
        question = _generateDefinitionQuestion(
          word: word,
          distractors: selectedDistractors,
          index: index,
        );
        break;
      case QuizQuestionType.reverseDefinition:
        question = _generateReverseDefinitionQuestion(
          word: word,
          distractors: selectedDistractors,
          index: index,
        );
        break;
      case QuizQuestionType.synonym:
        if (word.synonyms != null && word.synonyms!.isNotEmpty) {
          question = _generateSynonymQuestion(
            word: word,
            distractors: selectedDistractors,
            index: index,
          );
        } else {
          // Fallback to definition question
          question = _generateDefinitionQuestion(
            word: word,
            distractors: selectedDistractors,
            index: index,
          );
        }
        break;
      case QuizQuestionType.antonym:
        if (word.antonyms != null && word.antonyms!.isNotEmpty) {
          question = _generateAntonymQuestion(
            word: word,
            distractors: selectedDistractors,
            index: index,
          );
        } else {
          // Fallback to definition question
          question = _generateDefinitionQuestion(
            word: word,
            distractors: selectedDistractors,
            index: index,
          );
        }
        break;
      case QuizQuestionType.fillBlank:
        question = _generateFillBlankQuestion(
          word: word,
          distractors: selectedDistractors,
          index: index,
        );
        break;
    }

    return question;
  }

  /// Generate definition question (Word -> Definition)
  static QuizQuestion _generateDefinitionQuestion({
    required Word word,
    required List<Word> distractors,
    required int index,
  }) {
    // Shuffle options and place correct answer randomly
    final options = <QuizOption>[
      QuizOption(
        id: _uuid.v4(),
        text: word.definition,
        isCorrect: true,
      ),
      ...distractors.map((d) => QuizOption(
        id: _uuid.v4(),
        text: d.definition,
        isCorrect: false,
      )),
    ];

    options.shuffle();

    final correctIndex = options.indexWhere((o) => o.isCorrect);

    return QuizQuestion(
      id: _uuid.v4(),
      wordId: word.id,
      word: word.word,
      question: '"${word.word}" 的意思是？',
      type: QuizQuestionType.definition,
      options: options,
      correctOptionIndex: correctIndex,
      explanation: getExplanation(word),
      createdAt: DateTime.now(),
    );
  }

  /// Generate reverse definition question (Definition -> Word)
  static QuizQuestion _generateReverseDefinitionQuestion({
    required Word word,
    required List<Word> distractors,
    required int index,
  }) {
    final options = <QuizOption>[
      QuizOption(
        id: _uuid.v4(),
        text: word.word,
        isCorrect: true,
      ),
      ...distractors.map((d) => QuizOption(
        id: _uuid.v4(),
        text: d.word,
        isCorrect: false,
      )),
    ];

    options.shuffle();

    final correctIndex = options.indexWhere((o) => o.isCorrect);

    return QuizQuestion(
      id: _uuid.v4(),
      wordId: word.id,
      word: word.word,
      question: word.definition,
      type: QuizQuestionType.reverseDefinition,
      options: options,
      correctOptionIndex: correctIndex,
      explanation: getExplanation(word),
      createdAt: DateTime.now(),
    );
  }

  /// Generate synonym question
  static QuizQuestion _generateSynonymQuestion({
    required Word word,
    required List<Word> distractors,
    required int index,
  }) {
    // Use first synonym as correct answer
    final correctSynonym = word.synonyms!.first;

    // Generate wrong synonyms from distractors
    final wrongSynonyms = <String>[];
    for (final distractor in distractors) {
      if (distractor.synonyms != null && distractor.synonyms!.isNotEmpty) {
        wrongSynonyms.add(distractor.synonyms!.first);
        if (wrongSynonyms.length >= 3) break;
      }
    }

    // If not enough wrong synonyms, add some common ones
    final commonSynonyms = ['big', 'small', 'good', 'bad', 'happy', 'sad'];
    while (wrongSynonyms.length < 3) {
      final synonym = commonSynonyms[_random.nextInt(commonSynonyms.length)];
      if (synonym != correctSynonym && !wrongSynonyms.contains(synonym)) {
        wrongSynonyms.add(synonym);
      }
    }

    final options = <QuizOption>[
      QuizOption(
        id: _uuid.v4(),
        text: correctSynonym,
        isCorrect: true,
      ),
      ...wrongSynonyms.map((s) => QuizOption(
        id: _uuid.v4(),
        text: s,
        isCorrect: false,
      )),
    ];

    options.shuffle();

    final correctIndex = options.indexWhere((o) => o.isCorrect);

    return QuizQuestion(
      id: _uuid.v4(),
      wordId: word.id,
      word: word.word,
      question: '"${word.word}" 的同义词是？',
      type: QuizQuestionType.synonym,
      options: options,
      correctOptionIndex: correctIndex,
      explanation: '"${word.word}" 的同义词是 $correctSynonym',
      createdAt: DateTime.now(),
    );
  }

  /// Generate antonym question
  static QuizQuestion _generateAntonymQuestion({
    required Word word,
    required List<Word> distractors,
    required int index,
  }) {
    // Use first antonym as correct answer
    final correctAntonym = word.antonyms!.first;

    // Generate wrong antonyms from distractors
    final wrongAntonyms = <String>[];
    for (final distractor in distractors) {
      if (distractor.antonyms != null && distractor.antonyms!.isNotEmpty) {
        wrongAntonyms.add(distractor.antonyms!.first);
        if (wrongAntonyms.length >= 3) break;
      }
    }

    // If not enough wrong antonyms, add some common ones
    final commonAntonyms = ['big', 'small', 'good', 'bad', 'happy', 'sad'];
    while (wrongAntonyms.length < 3) {
      final antonym = commonAntonyms[_random.nextInt(commonAntonyms.length)];
      if (antonym != correctAntonym && !wrongAntonyms.contains(antonym)) {
        wrongAntonyms.add(antonym);
      }
    }

    final options = <QuizOption>[
      QuizOption(
        id: _uuid.v4(),
        text: correctAntonym,
        isCorrect: true,
      ),
      ...wrongAntonyms.map((a) => QuizOption(
        id: _uuid.v4(),
        text: a,
        isCorrect: false,
      )),
    ];

    options.shuffle();

    final correctIndex = options.indexWhere((o) => o.isCorrect);

    return QuizQuestion(
      id: _uuid.v4(),
      wordId: word.id,
      word: word.word,
      question: '"${word.word}" 的反义词是？',
      type: QuizQuestionType.antonym,
      options: options,
      correctOptionIndex: correctIndex,
      explanation: '"${word.word}" 的反义词是 $correctAntonym',
      createdAt: DateTime.now(),
    );
  }

  /// Generate fill-in-the-blank question
  static QuizQuestion _generateFillBlankQuestion({
    required Word word,
    required List<Word> distractors,
    required int index,
  }) {
    // Get an example sentence
    final example = word.examples.isNotEmpty
        ? word.examples.first
        : 'This is an example with ${word.word} in it.';

    // Replace the word with blank
    final blankedSentence = example.replaceAll(RegExp(r'\b${word.word}\b', caseSensitive: false), '_____');

    final options = <QuizOption>[
      QuizOption(
        id: _uuid.v4(),
        text: word.word,
        isCorrect: true,
      ),
      ...distractors.take(3).map((d) => QuizOption(
        id: _uuid.v4(),
        text: d.word,
        isCorrect: false,
      )),
    ];

    options.shuffle();

    final correctIndex = options.indexWhere((o) => o.isCorrect);

    return QuizQuestion(
      id: _uuid.v4(),
      wordId: word.id,
      word: word.word,
      question: blankedSentence,
      type: QuizQuestionType.fillBlank,
      options: options,
      correctOptionIndex: correctIndex,
      explanation: '正确答案是 "${word.word}" - ${word.definition}',
      createdAt: DateTime.now(),
    );
  }

  /// Get explanation for a word
  static String getExplanation(Word word) {
    final buffer = StringBuffer();
    buffer.write('${word.word}: ${word.definition}');
    if (word.phonetic != null) {
      buffer.write('\n发音: ${word.phonetic}');
    }
    if (word.examples.isNotEmpty) {
      buffer.write('\n例句: ${word.examples.first}');
    }
    return buffer.toString();
  }
}
