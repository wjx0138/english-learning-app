import 'package:flutter/material.dart';
import 'dart:math';

/// Quiz provider for managing test sessions
class QuizProvider extends ChangeNotifier {
  // Quiz configuration
  static const int _totalQuestions = 10;

  // Current quiz state
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  final List<int> _userAnswers = []; // Store user's answers (0-3, or -1 for wrong)

  // Statistics
  int _correctAnswers = 0;
  int get correctAnswers => _correctAnswers;
  int get wrongAnswers => _currentQuestionIndex - _correctAnswers;
  int get totalQuestions => _totalQuestions;

  // Getters
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizQuestion? get currentQuestion =>
      _currentQuestionIndex < _questions.length ? _questions[_currentQuestionIndex] : null;
  bool get isQuizComplete => _currentQuestionIndex >= _totalQuestions;
  double get accuracy => _currentQuestionIndex > 0
      ? _correctAnswers / _currentQuestionIndex
      : 0.0;

  /// Generate quiz questions from vocabulary
  void generateQuestions(List<dynamic> vocabulary) {
    _questions.clear();
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _correctAnswers = 0;

    // Shuffle vocabulary and take first 10 words
    final shuffled = List<dynamic>.from(vocabulary)..shuffle();
    final selectedWords = shuffled.take(_totalQuestions).toList();

    // Generate questions
    for (var wordJson in selectedWords) {
      _questions.add(QuizQuestion.fromWordJson(wordJson, vocabulary));
    }

    notifyListeners();
  }

  /// Submit answer for current question
  void submitAnswer(int selectedIndex) {
    if (_currentQuestionIndex >= _questions.length) return;

    final question = _questions[_currentQuestionIndex];
    final isCorrect = selectedIndex == question.correctAnswerIndex;

    if (isCorrect) {
      _correctAnswers++;
    }

    _userAnswers.add(selectedIndex);
    notifyListeners();
  }

  /// Move to next question
  void nextQuestion() {
    if (_currentQuestionIndex < _totalQuestions) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Reset quiz
  void resetQuiz() {
    _currentQuestionIndex = 0;
    _userAnswers.clear();
    _correctAnswers = 0;
    notifyListeners();
  }
}

/// Quiz question model
class QuizQuestion {
  final String word;
  final String phonetic;
  final String correctDefinition;
  final List<String> options;
  final int correctAnswerIndex;

  QuizQuestion({
    required this.word,
    required this.phonetic,
    required this.correctDefinition,
    required this.options,
    required this.correctAnswerIndex,
  });

  /// Create quiz question from word JSON
  factory QuizQuestion.fromWordJson(Map<String, dynamic> wordJson, List<dynamic> vocabulary) {
    final word = wordJson['word'] as String;
    final phonetic = wordJson['phonetic'] as String? ?? '';
    final correctDefinition = wordJson['definition'] as String;

    // Generate 3 wrong definitions
    final wrongDefinitions = <String>[];
    final random = Random();

    while (wrongDefinitions.length < 3) {
      final randomWord = vocabulary[random.nextInt(vocabulary.length)];
      final definition = randomWord['definition'] as String;

      // Make sure it's not the correct word and not already added
      if (randomWord['word'] != word && !wrongDefinitions.contains(definition)) {
        wrongDefinitions.add(definition);
      }
    }

    // Combine correct and wrong definitions, then shuffle
    final allOptions = [correctDefinition, ...wrongDefinitions];
    allOptions.shuffle();

    final correctIndex = allOptions.indexOf(correctDefinition);

    return QuizQuestion(
      word: word,
      phonetic: phonetic,
      correctDefinition: correctDefinition,
      options: allOptions,
      correctAnswerIndex: correctIndex,
    );
  }
}
