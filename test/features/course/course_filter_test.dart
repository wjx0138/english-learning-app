import 'package:flutter_test/flutter_test.dart';
import 'package:english_learning_app/shared/services/course_service.dart';

void main() {
  test('Filter courses by "考试" tag', () {
    final allCourses = CourseService.getAllCourses();

    print('=== All courses ===');
    for (final course in allCourses) {
      print('${course.name}: ${course.tags}');
    }

    final examCourses = allCourses.where((c) => c.tags.contains('考试')).toList();

    print('\n=== Courses with "考试" tag ===');
    for (final course in examCourses) {
      print(course.name);
    }

    expect(examCourses.length, 6, reason: 'Expected 6 courses with "考试" tag');
    expect(examCourses.any((c) => c.id == 'cet4_core'), true);
    expect(examCourses.any((c) => c.id == 'cet6_core'), true);
    expect(examCourses.any((c) => c.id == 'toefl_core'), true);
    expect(examCourses.any((c) => c.id == 'ielts_core'), true);
    expect(examCourses.any((c) => c.id == 'gre_essential'), true);
    expect(examCourses.any((c) => c.id == 'kaoyan_core'), true);
    expect(examCourses.any((c) => c.id == 'daily_conversation'), false,
        reason: 'Daily conversation should not have "考试" tag');
  });
}
