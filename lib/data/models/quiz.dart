/// Quiz data models for multiple choice questions

/// Quiz question model
class QuizQuestion {
  final String id;
  final String wordId;
  final String word;
  final String question;
  final QuizQuestionType type;
  final List<QuizOption> options;
  final int correctOptionIndex;
  final String? explanation;
  final DateTime createdAt;

  QuizQuestion({
    required this.id,
    required this.wordId,
    required this.word,
    required this.question,
    required this.type,
    required this.options,
    required this.correctOptionIndex,
    this.explanation,
    required this.createdAt,
  });

  /// Check if the given option index is correct
  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctOptionIndex;
  }

  /// Get the correct option
  QuizOption get correctOption => options[correctOptionIndex];

  QuizQuestion copyWith({
    String? id,
    String? wordId,
    String? word,
    String? question,
    QuizQuestionType? type,
    List<QuizOption>? options,
    int? correctOptionIndex,
    String? explanation,
    DateTime? createdAt,
  }) {
    return QuizQuestion(
      id: id ?? this.id,
      wordId: wordId ?? this.wordId,
      word: word ?? this.word,
      question: question ?? this.question,
      type: type ?? this.type,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      explanation: explanation ?? this.explanation,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wordId': wordId,
      'word': word,
      'question': question,
      'type': type.name,
      'options': options.map((o) => o.toJson()).toList(),
      'correctOptionIndex': correctOptionIndex,
      'explanation': explanation,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      wordId: json['wordId'] as String,
      word: json['word'] as String,
      question: json['question'] as String,
      type: QuizQuestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuizQuestionType.definition,
      ),
      options: (json['options'] as List)
          .map((o) => QuizOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      correctOptionIndex: json['correctOptionIndex'] as int,
      explanation: json['explanation'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Quiz option model
class QuizOption {
  final String id;
  final String text;
  final bool isCorrect;

  const QuizOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  QuizOption copyWith({
    String? id,
    String? text,
    bool? isCorrect,
  }) {
    return QuizOption(
      id: id ?? this.id,
      text: text ?? this.text,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
    };
  }

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] as String,
      text: json['text'] as String,
      isCorrect: json['isCorrect'] as bool,
    );
  }
}

/// Quiz question types
enum QuizQuestionType {
  /// Select correct definition for the word
  definition,

  /// Select the correct word for the definition
  reverseDefinition,

  /// Select the correct synonym
  synonym,

  /// Select the correct antonym
  antonym,

  /// Fill in the blank
  fillBlank,
}

/// Quiz session model
class QuizSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<QuizQuestion> questions;
  final List<QuizAnswer> answers;
  final QuizMode mode;

  QuizSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.questions,
    required this.answers,
    required this.mode,
  });

  /// Get total questions
  int get totalQuestions => questions.length;

  /// Get answered questions count
  int get answeredCount => answers.length;

  /// Get correct answers count
  int get correctCount => answers.where((a) => a.isCorrect).length;

  /// Get wrong answers count
  int get wrongCount => answeredCount - correctCount;

  /// Get accuracy percentage
  double get accuracy {
    if (answeredCount == 0) return 0.0;
    return (correctCount / answeredCount) * 100;
  }

  /// Get current question index
  int get currentQuestionIndex => answeredCount;

  /// Get current question
  QuizQuestion? get currentQuestion {
    if (currentQuestionIndex >= questions.length) return null;
    return questions[currentQuestionIndex];
  }

  /// Check if session is completed
  bool get isCompleted => currentQuestionIndex >= questions.length;

  /// Get list of wrong word IDs
  List<String> get wrongWordIds {
    return answers
        .where((a) => !a.isCorrect)
        .map((a) => questions[a.questionIndex].wordId)
        .toList();
  }

  QuizSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    List<QuizQuestion>? questions,
    List<QuizAnswer>? answers,
    QuizMode? mode,
  }) {
    return QuizSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      mode: mode ?? this.mode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'answers': answers.map((a) => a.toJson()).toList(),
      'mode': mode.name,
    };
  }

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
      answers: (json['answers'] as List)
          .map((a) => QuizAnswer.fromJson(a as Map<String, dynamic>))
          .toList(),
      mode: QuizMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => QuizMode.practice,
      ),
    );
  }
}

/// Quiz answer model
class QuizAnswer {
  final int questionIndex;
  final int selectedOptionIndex;
  final bool isCorrect;
  final Duration timeTaken;
  final DateTime timestamp;

  QuizAnswer({
    required this.questionIndex,
    required this.selectedOptionIndex,
    required this.isCorrect,
    required this.timeTaken,
    required this.timestamp,
  });

  QuizAnswer copyWith({
    int? questionIndex,
    int? selectedOptionIndex,
    bool? isCorrect,
    Duration? timeTaken,
    DateTime? timestamp,
  }) {
    return QuizAnswer(
      questionIndex: questionIndex ?? this.questionIndex,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      isCorrect: isCorrect ?? this.isCorrect,
      timeTaken: timeTaken ?? this.timeTaken,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionIndex': questionIndex,
      'selectedOptionIndex': selectedOptionIndex,
      'isCorrect': isCorrect,
      'timeTaken': timeTaken.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      questionIndex: json['questionIndex'] as int,
      selectedOptionIndex: json['selectedOptionIndex'] as int,
      isCorrect: json['isCorrect'] as bool,
      timeTaken: Duration(milliseconds: json['timeTaken'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

/// Quiz modes
enum QuizMode {
  /// Practice mode - instant feedback
  practice,

  /// Test mode - no feedback until end
  test,

  /// Timed mode - time limit per question
  timed,

  /// Challenge mode - streak bonus
  challenge,
}

/// Quiz settings
class QuizSettings {
  final int questionsPerSession;
  final int timeLimitSeconds; // For timed mode
  final bool showExplanations;
  final bool shuffleOptions;
  final bool allowReview;

  const QuizSettings({
    this.questionsPerSession = 20,
    this.timeLimitSeconds = 30,
    this.showExplanations = true,
    this.shuffleOptions = true,
    this.allowReview = true,
  });

  QuizSettings copyWith({
    int? questionsPerSession,
    int? timeLimitSeconds,
    bool? showExplanations,
    bool? shuffleOptions,
    bool? allowReview,
  }) {
    return QuizSettings(
      questionsPerSession: questionsPerSession ?? this.questionsPerSession,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      showExplanations: showExplanations ?? this.showExplanations,
      shuffleOptions: shuffleOptions ?? this.shuffleOptions,
      allowReview: allowReview ?? this.allowReview,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionsPerSession': questionsPerSession,
      'timeLimitSeconds': timeLimitSeconds,
      'showExplanations': showExplanations,
      'shuffleOptions': shuffleOptions,
      'allowReview': allowReview,
    };
  }

  factory QuizSettings.fromJson(Map<String, dynamic> json) {
    return QuizSettings(
      questionsPerSession: json['questionsPerSession'] as int? ?? 20,
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 30,
      showExplanations: json['showExplanations'] as bool? ?? true,
      shuffleOptions: json['shuffleOptions'] as bool? ?? true,
      allowReview: json['allowReview'] as bool? ?? true,
    );
  }
}
