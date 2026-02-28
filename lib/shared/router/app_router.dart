import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/home_page.dart';
import '../../features/flashcard/enhanced_flashcard_page.dart';
import '../../features/typing/typing_mode_selection_page.dart';
import '../../features/quiz/enhanced_quiz_page.dart';
import '../../features/progress/progress_page.dart';
import '../../features/vocabulary/vocabulary_list_page.dart';
import '../../features/settings/settings_page.dart';
import '../../features/error_book/error_book_page.dart';
import '../../features/course/course_selection_page.dart';
import '../../features/gamification/gamification_page.dart';

/// Application router configuration using go_router
class AppRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/flashcard',
        name: 'flashcard',
        builder: (context, state) => const EnhancedFlashcardPage(),
      ),
      GoRoute(
        path: '/typing',
        name: 'typing',
        builder: (context, state) => const TypingModeSelectionPage(),
      ),
      GoRoute(
        path: '/quiz',
        name: 'quiz',
        builder: (context, state) => const EnhancedQuizPage(),
      ),
      GoRoute(
        path: '/vocabulary',
        name: 'vocabulary',
        builder: (context, state) => const VocabularyListPage(),
      ),
      GoRoute(
        path: '/progress',
        name: 'progress',
        builder: (context, state) => const ProgressPage(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/error-book',
        name: 'error-book',
        builder: (context, state) => const ErrorBookPage(),
      ),
      GoRoute(
        path: '/courses',
        name: 'courses',
        builder: (context, state) => const CourseSelectionPage(),
      ),
      GoRoute(
        path: '/gamification',
        name: 'gamification',
        builder: (context, state) => const GamificationPage(),
      ),
    ],
  );
}

/// Placeholder widgets for unimplemented pages
class FlashcardPlaceholder extends StatelessWidget {
  const FlashcardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('卡片学习')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '卡片学习功能',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('开发中，敬请期待...'),
          ],
        ),
      ),
    );
  }
}

class TypingPlaceholder extends StatelessWidget {
  const TypingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('打字练习')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.keyboard, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '打字练习功能',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('开发中，敬请期待...'),
          ],
        ),
      ),
    );
  }
}

class ProgressPlaceholder extends StatelessWidget {
  const ProgressPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('学习统计')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '学习统计功能',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('开发中，敬请期待...'),
          ],
        ),
      ),
    );
  }
}
