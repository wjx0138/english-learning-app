/// Typing practice data models

/// Practice mode enum
enum TypingMode {
  /// Show the word while typing
  visible,

  /// Hide the word, listen to pronunciation (dictation)
  dictation,
}

/// Typing practice session
class TypingSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final TypingMode mode;
  final List<TypingResult> results;
  final List<String> wordIds;

  TypingSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.mode,
    required this.results,
    required this.wordIds,
  });

  /// Get total words practiced
  int get totalWords => results.length;

  /// Get correct words count
  int get correctWords => results.where((r) => r.isCorrect).length;

  /// Get wrong words count
  int get wrongWords => results.where((r) => !r.isCorrect).length;

  /// Get accuracy percentage
  double get accuracy {
    if (results.isEmpty) return 0.0;
    return (correctWords / totalWords) * 100;
  }

  /// Get average typing speed (characters per minute)
  double get averageCPM {
    if (results.isEmpty || endTime == null) return 0.0;
    final duration = endTime!.difference(startTime).inMinutes;
    if (duration == 0) return 0.0;

    final totalChars = results.fold<int>(
      0,
      (sum, r) => sum + r.userInput.length,
    );
    return totalChars / duration;
  }

  /// Get list of wrong word IDs for error book
  List<String> get wrongWordIds {
    return results
        .where((r) => !r.isCorrect)
        .map((r) => r.wordId)
        .toList();
  }

  TypingSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    TypingMode? mode,
    List<TypingResult>? results,
    List<String>? wordIds,
  }) {
    return TypingSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      mode: mode ?? this.mode,
      results: results ?? this.results,
      wordIds: wordIds ?? this.wordIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'mode': mode.name,
      'results': results.map((r) => r.toJson()).toList(),
      'wordIds': wordIds,
    };
  }

  factory TypingSession.fromJson(Map<String, dynamic> json) {
    return TypingSession(
      id: json['id'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      mode: TypingMode.values.firstWhere(
        (m) => m.name == json['mode'],
        orElse: () => TypingMode.visible,
      ),
      results: (json['results'] as List)
          .map((r) => TypingResult.fromJson(r as Map<String, dynamic>))
          .toList(),
      wordIds: List<String>.from(json['wordIds'] as List),
    );
  }
}

/// Single word typing result
class TypingResult {
  final String wordId;
  final String targetWord;
  final String userInput;
  final bool isCorrect;
  final Duration timeTaken;
  final DateTime timestamp;
  final int attempts; // How many times the user tried

  TypingResult({
    required this.wordId,
    required this.targetWord,
    required this.userInput,
    required this.isCorrect,
    required this.timeTaken,
    required this.timestamp,
    this.attempts = 1,
  });

  /// Get typing speed for this word (characters per minute)
  double get cpm {
    final minutes = timeTaken.inSeconds / 60.0;
    if (minutes == 0) return 0.0;
    return targetWord.length / minutes;
  }

  TypingResult copyWith({
    String? wordId,
    String? targetWord,
    String? userInput,
    bool? isCorrect,
    Duration? timeTaken,
    DateTime? timestamp,
    int? attempts,
  }) {
    return TypingResult(
      wordId: wordId ?? this.wordId,
      targetWord: targetWord ?? this.targetWord,
      userInput: userInput ?? this.userInput,
      isCorrect: isCorrect ?? this.isCorrect,
      timeTaken: timeTaken ?? this.timeTaken,
      timestamp: timestamp ?? this.timestamp,
      attempts: attempts ?? this.attempts,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'targetWord': targetWord,
      'userInput': userInput,
      'isCorrect': isCorrect,
      'timeTaken': timeTaken.inMilliseconds,
      'timestamp': timestamp.toIso8601String(),
      'attempts': attempts,
    };
  }

  factory TypingResult.fromJson(Map<String, dynamic> json) {
    return TypingResult(
      wordId: json['wordId'] as String,
      targetWord: json['targetWord'] as String,
      userInput: json['userInput'] as String,
      isCorrect: json['isCorrect'] as bool,
      timeTaken: Duration(milliseconds: json['timeTaken'] as int),
      timestamp: DateTime.parse(json['timestamp'] as String),
      attempts: json['attempts'] as int? ?? 1,
    );
  }
}

/// Typing practice settings
class TypingSettings {
  final bool soundEnabled;
  final bool autoPlayAudio;
  final double autoPlayDelay; // seconds
  final bool showHint;
  final int maxAttempts;
  final bool showProgress;

  const TypingSettings({
    this.soundEnabled = true,
    this.autoPlayAudio = false,
    this.autoPlayDelay = 1.0,
    this.showHint = true,
    this.maxAttempts = 3,
    this.showProgress = true,
  });

  TypingSettings copyWith({
    bool? soundEnabled,
    bool? autoPlayAudio,
    double? autoPlayDelay,
    bool? showHint,
    int? maxAttempts,
    bool? showProgress,
  }) {
    return TypingSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      autoPlayAudio: autoPlayAudio ?? this.autoPlayAudio,
      autoPlayDelay: autoPlayDelay ?? this.autoPlayDelay,
      showHint: showHint ?? this.showHint,
      maxAttempts: maxAttempts ?? this.maxAttempts,
      showProgress: showProgress ?? this.showProgress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'autoPlayAudio': autoPlayAudio,
      'autoPlayDelay': autoPlayDelay,
      'showHint': showHint,
      'maxAttempts': maxAttempts,
      'showProgress': showProgress,
    };
  }

  factory TypingSettings.fromJson(Map<String, dynamic> json) {
    return TypingSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      autoPlayAudio: json['autoPlayAudio'] as bool? ?? false,
      autoPlayDelay: (json['autoPlayDelay'] as num?)?.toDouble() ?? 1.0,
      showHint: json['showHint'] as bool? ?? true,
      maxAttempts: json['maxAttempts'] as int? ?? 3,
      showProgress: json['showProgress'] as bool? ?? true,
    );
  }
}
