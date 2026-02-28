import 'package:flutter/material.dart';
import '../../../data/models/quiz.dart';

/// Quiz Result Page
class QuizResultPage extends StatelessWidget {
  final QuizSession session;

  const QuizResultPage({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final sessionAccuracy = session.accuracy;
    final isExcellent = sessionAccuracy >= 90;
    final isGood = sessionAccuracy >= 70;

    return Scaffold(
      appBar: AppBar(
        title: const Text('测试完成'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Congratulations card
            _buildCompletionCard(context, sessionAccuracy, isExcellent, isGood),
            const SizedBox(height: 24),

            // Statistics grid
            _buildStatisticsGrid(context),
            const SizedBox(height: 24),

            // Wrong answers review
            if (session.wrongCount > 0) _buildWrongAnswersSection(context),
            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(
    BuildContext context,
    double accuracy,
    bool isExcellent,
    bool isGood,
  ) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExcellent
              ? [Colors.amber.shade400, Colors.amber.shade600]
              : isGood
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : [Colors.blue.shade400, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isExcellent
                        ? Colors.amber
                        : isGood
                            ? Colors.green
                            : Colors.blue)
                .shade200
                .withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isExcellent
                ? Icons.emoji_events
                : isGood
                    ? Icons.thumb_up
                    : Icons.school,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 24),
          Text(
            isExcellent
                ? '太棒了！'
                : isGood
                    ? '干得不错！'
                    : '继续努力！',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '正确率: ${accuracy.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '答对 ${session.correctCount}/${session.totalQuestions} 题',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
    final duration = session.endTime != null
        ? session.endTime!.difference(session.startTime)
        : Duration.zero;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          label: '正确',
          value: '${session.correctCount} 题',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildStatCard(
          context,
          label: '错误',
          value: '${session.wrongCount} 题',
          icon: Icons.cancel,
          color: Colors.red,
        ),
        _buildStatCard(
          context,
          label: '正确率',
          value: '${session.accuracy.toStringAsFixed(0)}%',
          icon: Icons.percent,
          color: Colors.blue,
        ),
        _buildStatCard(
          context,
          label: '用时',
          value: _formatDuration(duration),
          icon: Icons.timer,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWrongAnswersSection(BuildContext context) {
    final wrongAnswers = session.answers
        .where((a) => !a.isCorrect)
        .toList()
        ..sort((a, b) => a.questionIndex.compareTo(b.questionIndex));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '错题回顾',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Chip(
                  label: Text('${wrongAnswers.length} 题'),
                  backgroundColor: Colors.red.shade100,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...wrongAnswers.take(5).map((answer) {
              final question = session.questions[answer.questionIndex];
              final correctOption = question.correctOption;
              final selectedOption = question.options[answer.selectedOptionIndex];

              return ExpansionTile(
                title: Text(
                  '题目 ${answer.questionIndex + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  question.question.length > 50
                      ? '${question.question.substring(0, 50)}...'
                      : question.question,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAnswerRow(
                          '你的答案',
                          selectedOption.text,
                          Colors.red,
                        ),
                        const SizedBox(height: 8),
                        _buildAnswerRow(
                          '正确答案',
                          correctOption.text,
                          Colors.green,
                        ),
                        if (question.explanation != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              question.explanation!,
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }),
            if (wrongAnswers.length > 5)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '还有 ${wrongAnswers.length - 5} 道错题...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerRow(String label, String answer, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            answer,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          icon: const Icon(Icons.home),
          label: const Text('返回主页'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 12),
        if (session.wrongCount > 0)
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('错题本功能即将推出'),
                ),
              );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('复习错题'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }
}
