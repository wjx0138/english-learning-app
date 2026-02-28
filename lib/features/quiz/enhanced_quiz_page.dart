import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/word.dart';
import '../../data/models/quiz.dart';
import '../../data/models/gamification.dart';
import '../../core/providers/app_provider.dart';
import '../../shared/services/quiz_generator_service.dart';
import '../../shared/services/error_book_service.dart';
import '../../shared/services/gamification_service.dart';
import 'widgets/quiz_option_card.dart';
import 'quiz_result_page.dart';

/// Enhanced Quiz Page - Multiple Choice Questions
class EnhancedQuizPage extends StatefulWidget {
  const EnhancedQuizPage({super.key});

  @override
  State<EnhancedQuizPage> createState() => _EnhancedQuizPageState();
}

class _EnhancedQuizPageState extends State<EnhancedQuizPage> {
  late QuizSession _session;
  int? _selectedOptionIndex;
  bool _isRevealed = false;
  DateTime? _questionStartTime;

  @override
  void initState() {
    super.initState();
    _initializeQuiz();
  }

  void _initializeQuiz() {
    final words = context.read<AppProvider>().words;

    if (words.isEmpty) {
      return;
    }

    _session = QuizGeneratorService.generateQuizSession(
      words: words,
      mode: QuizMode.practice,
      questionCount: 20,
    );

    _questionStartTime = DateTime.now();
  }

  void _handleOptionSelect(int index) {
    if (_isRevealed) return;

    setState(() {
      _selectedOptionIndex = index;
      _isRevealed = true;
    });

    final currentQuestion = _session.currentQuestion!;
    final isCorrect = currentQuestion.isCorrect(index);
    final timeTaken = DateTime.now().difference(_questionStartTime!);

    // Record answer
    final answer = QuizAnswer(
      questionIndex: _session.currentQuestionIndex,
      selectedOptionIndex: index,
      isCorrect: isCorrect,
      timeTaken: timeTaken,
      timestamp: DateTime.now(),
    );

    setState(() {
      _session = _session.copyWith(
        answers: [..._session.answers, answer],
      );
    });

    // Collect wrong answers to error book
    if (!isCorrect) {
      ErrorBookService.addError(answer, currentQuestion);
    } else {
      // Add points for correct answer
      final appProvider = context.read<AppProvider>();
      appProvider.addPoints(2, type: PointEventType.correctAnswer);
    }

    // Auto-advance after delay
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        if (_session.isCompleted) {
          _showResults();
        } else {
          _nextQuestion();
        }
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      _selectedOptionIndex = null;
      _isRevealed = false;
      _questionStartTime = DateTime.now();
    });
  }

  void _showResults() {
    final completedSession = _session.copyWith(
      endTime: DateTime.now(),
    );

    final correctCount = completedSession.correctCount;
    final score = completedSession.accuracy.toInt();
    final appProvider = context.read<AppProvider>();

    // Add completion points
    appProvider.addPoints(
      10 + correctCount, // Base 10 points + correct answers
      type: PointEventType.completeQuiz,
    );

    // Record study activity with quiz score
    appProvider.recordStudy(
      correctAnswers: correctCount,
      quizScore: score,
    );

    // Check for perfect quiz achievement
    if (score == 100) {
      // Points for perfect quiz are already added by recordStudyActivity
      // Check achievements
      appProvider.checkAchievements();
    }

    // Check for other achievements
    appProvider.checkAchievements();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => QuizResultPage(
          session: completedSession,
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出测试？'),
        content: Text(
          '当前进度: ${_session.answeredCount}/${_session.totalQuestions}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('继续答题'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final words = context.watch<AppProvider>().words;

    if (words.isEmpty) {
      return _buildEmptyState();
    }

    if (_session.isCompleted) {
      return const SizedBox.shrink(); // Will be replaced by result page
    }

    final currentQuestion = _session.currentQuestion;

    if (currentQuestion == null) {
      return _buildLoadingState();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('选择题测试'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showExitDialog,
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text(
                  '${_session.currentQuestionIndex + 1}/${_session.totalQuestions}',
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_session.currentQuestionIndex + 1) / _session.totalQuestions,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            minHeight: 8,
          ),

          // Question and options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Question card
                  QuizQuestionCard(
                    question: currentQuestion,
                    currentIndex: _session.currentQuestionIndex,
                    totalQuestions: _session.totalQuestions,
                    isRevealed: _isRevealed,
                  ),
                  const SizedBox(height: 24),

                  // Options
                  ...currentQuestion.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;

                    return QuizOptionCard(
                      option: option,
                      index: index,
                      isSelected: _selectedOptionIndex == index,
                      isRevealed: _isRevealed,
                      showExplanation: true,
                      onTap: () => _handleOptionSelect(index),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择题测试'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              '请先选择词库',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.add),
              label: const Text('选择词库'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择题测试'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载题目中...'),
          ],
        ),
      ),
    );
  }
}
