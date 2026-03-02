import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/data/models/course.dart';

void main() {
  group('CourseDifficulty Enum Tests', () {
    test('Should have correct level values', () {
      expect(CourseDifficulty.beginner.level, 1);
      expect(CourseDifficulty.intermediate.level, 2);
      expect(CourseDifficulty.advanced.level, 3);
      expect(CourseDifficulty.expert.level, 4);
      expect(CourseDifficulty.exam.level, 5);
    });

    test('Should have correct labels', () {
      expect(CourseDifficulty.beginner.label, '初级');
      expect(CourseDifficulty.intermediate.label, '中级');
      expect(CourseDifficulty.advanced.label, '高级');
      expect(CourseDifficulty.expert.label, '专业');
      expect(CourseDifficulty.exam.label, '考试');
    });

    test('Should have descriptions', () {
      expect(CourseDifficulty.beginner.description, '适合英语初学者');
      expect(CourseDifficulty.exam.description, '备考专用');
    });
  });

  group('CourseTheme Enum Tests', () {
    test('Should have correct codes', () {
      expect(CourseTheme.cet4.code, 'CET-4');
      expect(CourseTheme.toefl.code, 'TOEFL');
      expect(CourseTheme.ielts.code, 'IELTS');
    });

    test('Should have correct labels', () {
      expect(CourseTheme.cet4.label, '大学英语四级');
      expect(CourseTheme.business.label, '商务英语');
    });

    test('Should have icons', () {
      expect(CourseTheme.cet4.icon != null, true);
      expect(CourseTheme.travel.icon != null, true);
    });
  });

  group('CourseProgress Model Tests', () {
    group('Constructor Tests', () {
      test('Should create progress with required fields', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
        );

        expect(progress.courseId, 'course-1');
        expect(progress.totalWords, 100);
        expect(progress.learnedWords, 0);
        expect(progress.masteredWords, 0);
        expect(progress.studyDays, 0);
        expect(progress.lastStudyTime, null);
      });

      test('Should create progress with all fields', () {
        final now = DateTime.now();
        final progress = CourseProgress(
          courseId: 'course-2',
          totalWords: 100,
          learnedWords: 50,
          masteredWords: 25,
          lastStudyTime: now,
          studyDays: 7,
        );

        expect(progress.learnedWords, 50);
        expect(progress.masteredWords, 25);
        expect(progress.lastStudyTime, now);
        expect(progress.studyDays, 7);
      });
    });

    group('Calculated Properties Tests', () {
      test('progressPercent should calculate correctly', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 50,
        );

        expect(progress.progressPercent, 0.5);
      });

      test('progressPercent should return 0 when totalWords is 0', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 0,
          learnedWords: 0,
        );

        expect(progress.progressPercent, 0.0);
      });

      test('progressPercent should handle edge case (100%)', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 100,
        );

        expect(progress.progressPercent, 1.0);
      });

      test('masteryRate should calculate correctly', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 50,
          masteredWords: 25,
        );

        expect(progress.masteryRate, 0.5);
      });

      test('masteryRate should return 0 when learnedWords is 0', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 0,
          masteredWords: 0,
        );

        expect(progress.masteryRate, 0.0);
      });

      test('hasStarted should return true when learnedWords > 0', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 1,
        );

        expect(progress.hasStarted, true);
      });

      test('hasStarted should return false when learnedWords is 0', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 0,
        );

        expect(progress.hasStarted, false);
      });

      test('isCompleted should return true when learnedWords >= totalWords', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 100,
        );

        expect(progress.isCompleted, true);
      });

      test('isCompleted should return false when learnedWords < totalWords', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 99,
        );

        expect(progress.isCompleted, false);
      });
    });

    group('copyWith Tests', () {
      test('Should create copy with updated learnedWords', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 50,
        );

        final updated = progress.copyWith(learnedWords: 60);

        expect(updated.learnedWords, 60);
        expect(updated.courseId, 'course-1');
        expect(updated.totalWords, 100);
      });

      test('Should create copy with multiple updates', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 50,
        );

        final now = DateTime.now();
        final updated = progress.copyWith(
          learnedWords: 75,
          masteredWords: 50,
          lastStudyTime: now,
        );

        expect(updated.learnedWords, 75);
        expect(updated.masteredWords, 50);
        expect(updated.lastStudyTime, now);
        expect(updated.totalWords, 100); // Unchanged
      });
    });

    group('Serialization Tests', () {
      test('Should serialize to JSON correctly', () {
        final now = DateTime(2026, 3, 2, 12, 0);
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 50,
          masteredWords: 25,
          lastStudyTime: now,
          studyDays: 7,
        );

        final json = progress.toJson();

        expect(json['courseId'], 'course-1');
        expect(json['totalWords'], 100);
        expect(json['learnedWords'], 50);
        expect(json['masteredWords'], 25);
        expect(json['lastStudyTime'], now.toIso8601String());
        expect(json['studyDays'], 7);
      });

      test('Should handle null lastStudyTime in serialization', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 50,
        );

        final json = progress.toJson();

        expect(json['lastStudyTime'], null);
      });

      test('Should deserialize from JSON correctly', () {
        final now = DateTime(2026, 3, 2, 12, 0);
        final json = {
          'courseId': 'course-1',
          'totalWords': 100,
          'learnedWords': 50,
          'masteredWords': 25,
          'lastStudyTime': now.toIso8601String(),
          'studyDays': 7,
        };

        final progress = CourseProgress.fromJson(json);

        expect(progress.courseId, 'course-1');
        expect(progress.totalWords, 100);
        expect(progress.learnedWords, 50);
        expect(progress.masteredWords, 25);
        expect(progress.lastStudyTime, now);
        expect(progress.studyDays, 7);
      });

      test('Should deserialize null lastStudyTime correctly', () {
        final json = {
          'courseId': 'course-1',
          'totalWords': 100,
          'learnedWords': 50,
          'masteredWords': 25,
          'lastStudyTime': null,
          'studyDays': 0,
        };

        final progress = CourseProgress.fromJson(json);

        expect(progress.lastStudyTime, null);
      });
    });

    group('Edge Cases Tests', () {
      test('Should handle zero totalWords', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 0,
          learnedWords: 0,
        );

        expect(progress.progressPercent, 0.0);
        expect(progress.hasStarted, false);
      });

      test('Should handle learnedWords exceeding totalWords', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 150,
        );

        expect(progress.progressPercent, greaterThan(1.0));
        expect(progress.isCompleted, true);
      });

      test('Should handle masteredWords exceeding learnedWords', () {
        final progress = CourseProgress(
          courseId: 'course-1',
          totalWords: 100,
          learnedWords: 50,
          masteredWords: 75, // More than learned
        );

        expect(progress.masteryRate, greaterThan(1.0));
      });
    });
  });
}
