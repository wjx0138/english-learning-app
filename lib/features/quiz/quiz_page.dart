import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/quiz_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../shared/services/tts_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final TTSService _ttsService = TTSService();
  bool _isLoading = true;
  bool _hasAnswered = false;
  int? _selectedOptionIndex;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final jsonString = await rootBundle.loadString('assets/vocabularies/cet4_sample.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      context.read<QuizProvider>().generateQuestions(jsonList);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectOption(int index) {
    if (_hasAnswered) return;

    final provider = context.read<QuizProvider>();
    final question = provider.currentQuestion!;
    final isCorrect = index == question.correctAnswerIndex;

    setState(() {
      _hasAnswered = true;
      _selectedOptionIndex = index;
      _isCorrect = isCorrect;
    });

    provider.submitAnswer(index);

    // Auto-advance after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        if (provider.currentQuestionIndex < provider.totalQuestions - 1) {
          setState(() {
            _hasAnswered = false;
            _selectedOptionIndex = null;
          });
          provider.nextQuestion();
        } else {
          provider.nextQuestion();
        }
      }
    });
  }

  void _restartQuiz() {
    context.read<QuizProvider>().resetQuiz();
    setState(() {
      _isLoading = true;
      _hasAnswered = false;
      _selectedOptionIndex = null;
    });
    _loadQuiz();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择题测试'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          if (!_isLoading && !context.read<QuizProvider>().isQuizComplete)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Chip(
                  label: Text(
                    '进度: ${context.read<QuizProvider>().currentQuestionIndex + 1}/${context.read<QuizProvider>().totalQuestions}',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (_isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('加载题目中...'),
                ],
              ),
            );
          }

          if (provider.isQuizComplete) {
            return _buildResultPage(context, provider);
          }

          final question = provider.currentQuestion;
          if (question == null) {
            return const Center(child: Text('题目加载失败'));
          }

          return _buildQuizPage(context, provider, question);
        },
      ),
    );
  }

  Widget _buildQuizPage(BuildContext context, QuizProvider provider, QuizQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (provider.currentQuestionIndex + 1) / provider.totalQuestions,
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(height: 32),

          // Word card
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Speaker button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => _ttsService.speakWord(question.word),
                        icon: const Icon(
                          Icons.volume_up,
                          color: Colors.grey,
                        ),
                        tooltip: '播放发音',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Word
                  Text(
                    question.word,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ),
                  const SizedBox(height: 8),

                  // Phonetic
                  if (question.phonetic.isNotEmpty)
                    Text(
                      question.phonetic,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Options
          Text(
            '请选择正确的释义',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          ...List.generate(question.options.length, (index) {
            final isSelected = _selectedOptionIndex == index;
            final isCorrectOption = index == question.correctAnswerIndex;

            Color? backgroundColor;
            Color? textColor;
            IconData? trailingIcon;

            if (_hasAnswered) {
              if (isSelected && isCorrectOption) {
                // Selected and correct
                backgroundColor = Colors.green[100];
                textColor = Colors.green[900];
                trailingIcon = Icons.check_circle;
              } else if (isSelected && !isCorrectOption) {
                // Selected but wrong
                backgroundColor = Colors.red[100];
                textColor = Colors.red[900];
                trailingIcon = Icons.cancel;
              } else if (!isSelected && isCorrectOption) {
                // Not selected but is correct answer
                backgroundColor = Colors.green[50];
                textColor = Colors.green[700];
                trailingIcon = Icons.check_circle_outline;
              }
            } else if (isSelected) {
              // Selected but not answered yet
              backgroundColor = Theme.of(context).colorScheme.primaryContainer;
              textColor = Theme.of(context).colorScheme.onPrimaryContainer;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () => _selectOption(index),
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: textColor,
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.centerLeft,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _hasAnswered
                          ? (backgroundColor ?? Colors.transparent)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        ['A. ', 'B. ', 'C. ', 'D. '][index] + question.options[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    if (trailingIcon != null)
                      Icon(
                        trailingIcon,
                        color: textColor,
                      ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Feedback message
          if (_hasAnswered)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isCorrect ? Colors.green[100] : Colors.red[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isCorrect ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isCorrect ? Icons.check_circle : Icons.error,
                    color: _isCorrect ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCorrect ? '回答正确！' : '回答错误',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isCorrect ? Colors.green[900] : Colors.red[900],
                          ),
                        ),
                        if (!_isCorrect)
                          Text(
                            '正确答案: ${['A', 'B', 'C', 'D'][question.correctAnswerIndex]}. ${question.correctDefinition}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green[800],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultPage(BuildContext context, QuizProvider provider) {
    final accuracy = provider.accuracy;
    final percentage = (accuracy * 100).toInt();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Trophy icon
            Icon(
              percentage >= 80
                  ? Icons.emoji_events
                  : percentage >= 60
                      ? Icons.star
                      : Icons.school,
              size: 100,
              color: percentage >= 80
                  ? Colors.amber
                  : percentage >= 60
                      ? Colors.blue
                      : Colors.grey,
            ),
            const SizedBox(height: 32),

            // Result title
            Text(
              percentage >= 80 ? '优秀！' : percentage >= 60 ? '良好！' : '继续加油！',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: percentage >= 80
                        ? Colors.amber
                        : percentage >= 60
                            ? Colors.blue
                            : Colors.grey,
                  ),
            ),
            const SizedBox(height: 16),

            // Score
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Column(
                children: [
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  Text(
                    '正确率',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Statistics
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem('正确', '${provider.correctAnswers}', Icons.check_circle, Colors.green),
                const SizedBox(width: 32),
                _buildStatItem('错误', '${provider.wrongAnswers}', Icons.cancel, Colors.red),
              ],
            ),
            const SizedBox(height: 48),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _restartQuiz,
                  icon: const Icon(Icons.refresh),
                  label: const Text('重新测试'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    // Record progress
                    final progressProvider = context.read<ProgressProvider>();
                    progressProvider.recordStudySession(
                      cardsStudied: provider.totalQuestions,
                      correctAnswers: provider.correctAnswers,
                      wrongAnswers: provider.wrongAnswers,
                    );
                    context.pop();
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('返回首页'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
