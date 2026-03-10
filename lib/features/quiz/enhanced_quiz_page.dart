import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/word.dart';
import '../../data/models/quiz.dart';
import '../../data/models/gamification.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/progress_provider.dart';
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
  bool _isQuestionVisible = true; // 控制题目显示
  DateTime? _questionStartTime;
  QuizQuestion? _displayedQuestion; // 缓存当前显示的题目
  int _displayedQuestionIndex = 0; // 显示的题目索引（用于进度显示）
  late ProgressProvider _progressProvider; // Save reference for safe use in dispose

  @override
  void initState() {
    // Save Provider reference for safe use in dispose
    _progressProvider = context.read<ProgressProvider>();
    super.initState();
    _initializeQuiz();
  }

  void _initializeQuiz() {
    final appProvider = context.read<AppProvider>();
    // Use saved _progressProvider reference
    final progressProvider = _progressProvider;
    final allWords = appProvider.words;

    if (allWords.isEmpty) {
      return;
    }

    // 使用与闪卡学习相同的词汇范围：前 N 个词汇
    final quizWords = allWords.take(progressProvider.dailyGoal).toList();

    _session = QuizGeneratorService.generateQuizSession(
      words: quizWords,
      mode: QuizMode.practice,
      questionCount: progressProvider.dailyGoal,
    );

    _displayedQuestion = _session.currentQuestion; // 缓存初始题目
    _displayedQuestionIndex = 0; // 初始化显示的题目索引
    _questionStartTime = DateTime.now();
  }

  @override
  void dispose() {
    // Don't record in dispose - Provider may already be destroyed
    // Progress is recorded when user explicitly exits or completes session
    super.dispose();
  }

  /// Record study session when user exits the page (enters page -> leaves page)
  Future<void> _recordStudySessionOnExit() async {
    // Don't record if already completed or no questions answered
    if (_session.endTime != null) return;
    if (_session.answers.isEmpty) return;

    try {
      // Set end time
      _session = _session.copyWith(endTime: DateTime.now());

      // Calculate study time in minutes
      final studyDuration = _session.endTime!.difference(_session.startTime);
      final studyMinutes = studyDuration.inSeconds > 0
          ? (studyDuration.inSeconds / 60).ceil()
          : 0;

      if (studyMinutes <= 0) return;

      // Get correct word IDs
      final correctWordIds = _session.answers
          .where((a) => a.isCorrect)
          .map((a) => _session.questions[a.questionIndex].wordId)
          .toList();

      final progressProvider = _progressProvider;
      await progressProvider.recordStudySession(
        cardsStudied: _session.answeredCount,  // Use actual answered count, not total questions
        correctAnswers: _session.correctCount,
        wrongAnswers: _session.wrongCount,
        correctWordIds: correctWordIds,
        studyMinutes: studyMinutes,
        studyMode: 'quiz',
      );
    } catch (e) {
      // Provider might not be available during dispose
      // ignore: avoid_print
      print('Error recording study session: $e');
    }
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
        // 先淡出当前题目和选项
        setState(() {
          _isQuestionVisible = false;
        });

        // 等待淡出动画完成，然后切换到下一题
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            if (_session.isCompleted) {
              _showResults();
            } else {
              // 更新到下一题（此时用户看不到）
              setState(() {
                _displayedQuestion = _session.currentQuestion; // 缓存下一题
                _displayedQuestionIndex = _session.currentQuestionIndex; // 更新显示的题目索引
              });

              // 同时淡入下一题的题目和选项
              setState(() {
                _selectedOptionIndex = null;
                _isRevealed = false;
                _isQuestionVisible = true;
                _questionStartTime = DateTime.now();
              });
            }
          }
        });
      }
    });
  }

  Future<void> _showResults() async {
    // Set end time and record study session
    await _recordStudySessionOnExit();

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

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => QuizResultPage(
            session: completedSession,
          ),
        ),
      );
    }
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

    if (_displayedQuestion == null) {
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
                  '${_displayedQuestionIndex + 1}/${_session.totalQuestions}',
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
            value: (_displayedQuestionIndex + 1) / _session.totalQuestions,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            minHeight: 8,
          ),

          // Question and options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Question card - 同步显示/隐藏
                  AnimatedOpacity(
                    opacity: _isQuestionVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: _isQuestionVisible
                        ? QuizQuestionCard(
                            question: _displayedQuestion!,
                            currentIndex: _displayedQuestionIndex,
                            totalQuestions: _session.totalQuestions,
                            isRevealed: _isRevealed,
                          )
                        : const SizedBox(
                            height: 200, // 占位高度，避免跳动
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Options - 与题目同步显示/隐藏
                  ..._displayedQuestion!.options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;

                    return AnimatedOpacity(
                      opacity: _isQuestionVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: QuizOptionCard(
                        option: option,
                        index: index,
                        isSelected: _selectedOptionIndex == index,
                        isRevealed: _isRevealed,
                        showExplanation: true,
                        onTap: () => _handleOptionSelect(index),
                      ),
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
                context.go('/vocabulary-selection');
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
