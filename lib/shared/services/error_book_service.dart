import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../data/models/error_book.dart';
import '../../data/models/quiz.dart';

/// 错题本服务 - 管理错��的存储和检索
class ErrorBookService {
  static const String _errorBookKey = 'error_book_data';
  static ErrorBook? _cachedErrorBook;

  /// 获取错题本
  static Future<ErrorBook> getErrorBook() async {
    if (_cachedErrorBook != null) {
      return _cachedErrorBook!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_errorBookKey);

      if (jsonString == null) {
        _cachedErrorBook = ErrorBook();
        return _cachedErrorBook!;
      }

      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final errors = jsonList.map((json) {
        return ErrorRecord(
          id: json['id'] as String,
          question: QuizQuestion(
            id: json['question']['id'] as String,
            wordId: json['question']['wordId'] as String,
            word: json['question']['word'] as String,
            question: json['question']['question'] as String,
            type: QuizQuestionType.values.firstWhere(
              (e) => e.name == json['question']['type'],
              orElse: () => QuizQuestionType.definition,
            ),
            options: (json['question']['options'] as List<dynamic>)
                .map((opt) => QuizOption(
                      id: opt['id'] as String,
                      text: opt['text'] as String,
                      isCorrect: opt['isCorrect'] as bool,
                    ))
                .toList(),
            correctOptionIndex: json['question']['correctOptionIndex'] as int,
            explanation: json['question']['explanation'] as String?,
            createdAt: DateTime.parse(json['question']['createdAt'] as String),
          ),
          wrongOptionIndex: json['wrongOptionIndex'] as int?,
          wrongTime: DateTime.parse(json['wrongTime'] as String),
          reviewCount: json['reviewCount'] as int? ?? 0,
          lastReviewTime: json['lastReviewTime'] != null
              ? DateTime.parse(json['lastReviewTime'] as String)
              : null,
          isMastered: json['isMastered'] as bool? ?? false,
          wrongOptionsHistory: (json['wrongOptionsHistory'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toList() ??
              [],
        );
      }).toList();

      _cachedErrorBook = ErrorBook(errors: errors);
      return _cachedErrorBook!;
    } catch (e) {
      // 如果出错，返回空的错题本
      _cachedErrorBook = ErrorBook();
      return _cachedErrorBook!;
    }
  }

  /// 保存错题本
  static Future<void> saveErrorBook(ErrorBook errorBook) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> jsonList = errorBook.errors.map((error) {
        return {
          'id': error.id,
          'question': {
            'id': error.question.id,
            'wordId': error.question.wordId,
            'word': error.question.word,
            'question': error.question.question,
            'type': error.question.type.name,
            'options': error.question.options.map((opt) => {
              'id': opt.id,
              'text': opt.text,
              'isCorrect': opt.isCorrect,
            }).toList(),
            'correctOptionIndex': error.question.correctOptionIndex,
            'explanation': error.question.explanation,
            'createdAt': error.question.createdAt.toIso8601String(),
          },
          'wrongOptionIndex': error.wrongOptionIndex,
          'wrongTime': error.wrongTime.toIso8601String(),
          'reviewCount': error.reviewCount,
          'lastReviewTime': error.lastReviewTime?.toIso8601String(),
          'isMastered': error.isMastered,
          'wrongOptionsHistory': error.wrongOptionsHistory,
        };
      }).toList();

      await prefs.setString(_errorBookKey, json.encode(jsonList));
      _cachedErrorBook = errorBook;
    } catch (e) {
      // 忽略保存错误
    }
  }

  /// 添加错题
  static Future<void> addError(QuizAnswer answer, QuizQuestion question) async {
    // 只记录答错的题目
    if (answer.isCorrect) return;

    final errorBook = await getErrorBook();
    final errorRecord = ErrorRecord.fromQuizAnswer(answer, question);
    final updated = errorBook.addError(errorRecord);
    await saveErrorBook(updated);
  }

  /// 批量添加错题
  static Future<void> addErrors(List<QuizAnswer> answers, List<QuizQuestion> questions) async {
    final errorBook = await getErrorBook();
    ErrorBook updated = errorBook;

    for (int i = 0; i < answers.length; i++) {
      final answer = answers[i];
      final question = i < questions.length ? questions[i] : questions.first;

      // 只记录答错的题目
      if (!answer.isCorrect) {
        final errorRecord = ErrorRecord.fromQuizAnswer(answer, question);
        updated = updated.addError(errorRecord);
      }
    }

    await saveErrorBook(updated);
  }

  /// 移除错题
  static Future<void> removeError(String errorId) async {
    final errorBook = await getErrorBook();
    final updated = errorBook.removeError(errorId);
    await saveErrorBook(updated);
  }

  /// 标记为已掌握
  static Future<void> markAsMastered(String errorId) async {
    final errorBook = await getErrorBook();
    final updated = errorBook.markAsMastered(errorId);
    await saveErrorBook(updated);
  }

  /// 清空已掌握的错题
  static Future<void> clearMastered() async {
    final errorBook = await getErrorBook();
    final updated = errorBook.clearMastered();
    await saveErrorBook(updated);
  }

  /// 清空所有错题
  static Future<void> clearAll() async {
    await saveErrorBook(ErrorBook());
  }

  /// 清除缓存
  static void clearCache() {
    _cachedErrorBook = null;
  }

  /// 获取统计信息
  static Future<ErrorBookStats> getStats() async {
    final errorBook = await getErrorBook();
    return errorBook.stats;
  }
}
