/// Learning statistics data model for charts
class LearningData {
  final DateTime date;
  final int wordsLearned;
  final int studyMinutes;
  final int accuracy; // 0-100

  LearningData({
    required this.date,
    required this.wordsLearned,
    required this.studyMinutes,
    required this.accuracy,
  });

  LearningData copyWith({
    DateTime? date,
    int? wordsLearned,
    int? studyMinutes,
    int? accuracy,
  }) {
    return LearningData(
      date: date ?? this.date,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      studyMinutes: studyMinutes ?? this.studyMinutes,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'wordsLearned': wordsLearned,
      'studyMinutes': studyMinutes,
      'accuracy': accuracy,
    };
  }

  factory LearningData.fromJson(Map<String, dynamic> json) {
    return LearningData(
      date: DateTime.parse(json['date'] as String),
      wordsLearned: json['wordsLearned'] as int,
      studyMinutes: json['studyMinutes'] as int,
      accuracy: json['accuracy'] as int,
    );
  }
}

/// Vocabulary growth data model
class VocabularyGrowthData {
  final DateTime date;
  final int totalWords;
  final int newWords; // Words learned on this day

  VocabularyGrowthData({
    required this.date,
    required this.totalWords,
    required this.newWords,
  });

  VocabularyGrowthData copyWith({
    DateTime? date,
    int? totalWords,
    int? newWords,
  }) {
    return VocabularyGrowthData(
      date: date ?? this.date,
      totalWords: totalWords ?? this.totalWords,
      newWords: newWords ?? this.newWords,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'totalWords': totalWords,
      'newWords': newWords,
    };
  }

  factory VocabularyGrowthData.fromJson(Map<String, dynamic> json) {
    return VocabularyGrowthData(
      date: DateTime.parse(json['date'] as String),
      totalWords: json['totalWords'] as int,
      newWords: json['newWords'] as int,
    );
  }
}
