import 'quiz.dart';

/// 错题记录模型
class ErrorRecord {
  final String id;
  final QuizQuestion question;
  final int? wrongOptionIndex;  // 用户选择的错误选项
  final DateTime wrongTime;
  final int reviewCount;         // 复习次数
  final DateTime? lastReviewTime;
  final bool isMastered;         // 是否已掌握
  final List<int> wrongOptionsHistory; // 历史错题选项记录

  ErrorRecord({
    required this.id,
    required this.question,
    required this.wrongOptionIndex,
    required this.wrongTime,
    this.reviewCount = 0,
    this.lastReviewTime,
    this.isMastered = false,
    this.wrongOptionsHistory = const [],
  });

  /// 从quiz答案创建错题记录
  factory ErrorRecord.fromQuizAnswer(QuizAnswer answer, QuizQuestion question) {
    return ErrorRecord(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}_${question.id}',
      question: question,
      wrongOptionIndex: answer.selectedOptionIndex,
      wrongTime: answer.timestamp,
      wrongOptionsHistory: [answer.selectedOptionIndex],
    );
  }

  /// 标记为已掌握
  ErrorRecord markAsMastered() {
    return ErrorRecord(
      id: id,
      question: question,
      wrongOptionIndex: wrongOptionIndex,
      wrongTime: wrongTime,
      reviewCount: reviewCount + 1,
      lastReviewTime: DateTime.now(),
      isMastered: true,
      wrongOptionsHistory: wrongOptionsHistory,
    );
  }

  /// 增加复习次数
  ErrorRecord incrementReview() {
    return ErrorRecord(
      id: id,
      question: question,
      wrongOptionIndex: wrongOptionIndex,
      wrongTime: wrongTime,
      reviewCount: reviewCount + 1,
      lastReviewTime: DateTime.now(),
      isMastered: isMastered,
      wrongOptionsHistory: wrongOptionsHistory,
    );
  }

  /// 添加新的错误选项
  ErrorRecord addWrongOption(int optionIndex) {
    return ErrorRecord(
      id: id,
      question: question,
      wrongOptionIndex: optionIndex,
      wrongTime: DateTime.now(),
      reviewCount: reviewCount,
      lastReviewTime: lastReviewTime,
      isMastered: false,  // 再次答错，重置掌握状态
      wrongOptionsHistory: [...wrongOptionsHistory, optionIndex],
    );
  }

  /// 获取错题的单词ID
  String get wordId => question.wordId;

  /// 获取错题的单词
  String get word => question.word;

  /// 获取题目类型
  QuizQuestionType get type => question.type;
}

/// 错题本模型
class ErrorBook {
  final List<ErrorRecord> errors;

  ErrorBook({this.errors = const []});

  /// 添加错题
  ErrorBook addError(ErrorRecord error) {
    // 检查是否已存在该题目的错题记录
    final existingIndex = errors.indexWhere((e) => e.question.id == error.question.id);
    if (existingIndex != -1) {
      // 如果存在，更新错误记录
      final updated = List<ErrorRecord>.from(errors);
      updated[existingIndex] = errors[existingIndex].addWrongOption(error.wrongOptionIndex!);
      return ErrorBook(errors: updated);
    }
    // 如果不存在，添加新记录
    return ErrorBook(errors: [...errors, error]);
  }

  /// 移除错题（掌握后）
  ErrorBook removeError(String errorId) {
    return ErrorBook(
      errors: errors.where((e) => e.id != errorId).toList(),
    );
  }

  /// 标记为已掌握
  ErrorBook markAsMastered(String errorId) {
    return ErrorBook(
      errors: errors.map((e) {
        if (e.id == errorId) {
          return e.markAsMastered();
        }
        return e;
      }).toList(),
    );
  }

  /// 获取未掌握的错题
  List<ErrorRecord> get unmasteredErrors => errors.where((e) => !e.isMastered).toList();

  /// 获取已掌握的错题
  List<ErrorRecord> get masteredErrors => errors.where((e) => e.isMastered).toList();

  /// 按单词ID分组错题
  Map<String, List<ErrorRecord>> get errorsByWord {
    final Map<String, List<ErrorRecord>> grouped = {};
    for (final error in errors) {
      if (!grouped.containsKey(error.wordId)) {
        grouped[error.wordId] = [];
      }
      grouped[error.wordId]!.add(error);
    }
    return grouped;
  }

  /// 按题型分组
  Map<QuizQuestionType, List<ErrorRecord>> get errorsByType {
    final Map<QuizQuestionType, List<ErrorRecord>> grouped = {};
    for (final error in errors) {
      if (!grouped.containsKey(error.type)) {
        grouped[error.type] = [];
      }
      grouped[error.type]!.add(error);
    }
    return grouped;
  }

  /// 统计信息
  ErrorBookStats get stats {
    return ErrorBookStats(
      totalErrors: errors.length,
      unmasteredCount: unmasteredErrors.length,
      masteredCount: masteredErrors.length,
      wordCount: errorsByWord.keys.length,
    );
  }

  /// 清空已掌握的错题
  ErrorBook clearMastered() {
    return ErrorBook(errors: unmasteredErrors);
  }
}

/// 错题本统计信息
class ErrorBookStats {
  final int totalErrors;
  final int unmasteredCount;
  final int masteredCount;
  final int wordCount;

  ErrorBookStats({
    required this.totalErrors,
    required this.unmasteredCount,
    required this.masteredCount,
    required this.wordCount,
  });

  /// 掌握率
  double get masteryRate {
    if (totalErrors == 0) return 1.0;
    return masteredCount / totalErrors;
  }

  /// 掌握率百分比
  String get masteryRatePercentage => '${(masteryRate * 100).toStringAsFixed(1)}%';
}
