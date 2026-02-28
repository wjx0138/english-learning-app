import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/learning_data.dart';

/// Service for generating and managing chart data
class ChartDataService {
  /// Generate mock learning data for the last 7 days
  static List<LearningData> generateMockLearningData() {
    final now = DateTime.now();
    final data = <LearningData>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Generate realistic mock data
      final wordsLearned = 10 + (i * 5) + (i % 3 * 8); // 10-45 words per day
      final studyMinutes = 15 + (i * 10) + (i % 2 * 20); // 15-75 minutes
      final accuracy = 65 + (i * 4) + (i % 5 * 10); // 65-95% accuracy

      data.add(LearningData(
        date: date,
        wordsLearned: wordsLearned,
        studyMinutes: studyMinutes,
        accuracy: accuracy.clamp(60, 100),
      ));
    }

    return data;
  }

  /// Generate mock vocabulary growth data for the last 30 days
  static List<VocabularyGrowthData> generateMockVocabularyGrowthData() {
    final now = DateTime.now();
    final data = <VocabularyGrowthData>[];
    var totalWords = 0;

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // Simulate learning new words
      final newWords = i < 25
          ? 5 + (i % 10) + (i % 3 * 8) // More words at beginning
          : 2 + (i % 5); // Fewer words later

      totalWords += newWords;

      // Only add data for days when new words were learned
      if (i < 28 || newWords > 0) {
        data.add(VocabularyGrowthData(
          date: date,
          totalWords: totalWords,
          newWords: newWords,
        ));
      }
    }

    return data;
  }

  /// Calculate total study time from learning data
  static Duration calculateTotalStudyTime(List<LearningData> data) {
    return data.fold(
      Duration.zero,
      (total, data) => total + Duration(minutes: data.studyMinutes),
    );
  }

  /// Calculate average accuracy from learning data
  static double calculateAverageAccuracy(List<LearningData> data) {
    if (data.isEmpty) return 0.0;

    final totalAccuracy = data.fold<int>(0, (sum, data) => sum + data.accuracy);
    return totalAccuracy / data.length;
  }

  /// Get today's learning stats
  static Map<String, dynamic> getTodayStats(List<LearningData> data) {
    if (data.isEmpty) {
      return {
        'wordsLearned': 0,
        'studyMinutes': 0,
        'accuracy': 0,
      };
    }

    final todayData = data.last;
    return {
      'wordsLearned': todayData.wordsLearned,
      'studyMinutes': todayData.studyMinutes,
      'accuracy': todayData.accuracy,
    };
  }

  /// Get this week's learning summary
  static Map<String, dynamic> getWeeklySummary(List<LearningData> data) {
    if (data.isEmpty) {
      return {
        'totalWords': 0,
        'totalMinutes': 0,
        'averageAccuracy': 0.0,
        'activeDays': 0,
      };
    }

    final totalWords = data.fold<int>(0, (sum, data) => sum + data.wordsLearned);
    final totalMinutes = data.fold<int>(0, (sum, data) => sum + data.studyMinutes);
    final activeDays = data.where((d) => d.studyMinutes > 0).length;

    return {
      'totalWords': totalWords,
      'totalMinutes': totalMinutes,
      'averageAccuracy': calculateAverageAccuracy(data),
      'activeDays': activeDays,
    };
  }

  /// Get vocabulary growth percentage
  static double getVocabularyGrowthPercentage(List<VocabularyGrowthData> data) {
    if (data.length < 2) return 0.0;

    final firstWords = data.first.totalWords.toDouble();
    final lastWords = data.last.totalWords.toDouble();

    if (firstWords == 0) return 100.0;
    return ((lastWords - firstWords) / firstWords * 100);
  }
}
