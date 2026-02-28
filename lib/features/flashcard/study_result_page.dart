import 'package:flutter/material.dart';

/// Flashcard Study Session Results Page
class StudyResultPage extends StatelessWidget {
  final int totalCards;
  final int correctCards;
  final int wrongCards;
  final Duration studyDuration;
  final List<String> wrongWordIds;

  const StudyResultPage({
    super.key,
    required this.totalCards,
    required this.correctCards,
    required this.wrongCards,
    required this.studyDuration,
    this.wrongWordIds = const [],
  });

  double get accuracy {
    if (totalCards == 0) return 0.0;
    return (correctCards / totalCards) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isExcellent = accuracy >= 90;
    final isGood = accuracy >= 70;

    return Scaffold(
      appBar: AppBar(
        title: const Text('学习完成'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Congratulations card
            _buildCompletionCard(context, isExcellent, isGood),
            const SizedBox(height: 24),

            // Statistics cards
            _buildStatisticsGrid(context),
            const SizedBox(height: 24),

            // Wrong words section
            if (wrongCards > 0) _buildWrongWordsSection(context),
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
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(BuildContext context) {
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
          label: '学习卡片',
          value: '$totalCards',
          icon: Icons.style,
          color: Colors.blue,
        ),
        _buildStatCard(
          context,
          label: '正确',
          value: '$correctCards',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildStatCard(
          context,
          label: '错误',
          value: '$wrongCards',
          icon: Icons.cancel,
          color: Colors.red,
        ),
        _buildStatCard(
          context,
          label: '学习时长',
          value: _formatDuration(studyDuration),
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

  Widget _buildWrongWordsSection(BuildContext context) {
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
                  '需要复习的单词',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Chip(
                  label: Text('$wrongCards 个'),
                  backgroundColor: Colors.red.shade100,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '这些单词已加入错题本，您可以在稍后复习它们。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              wrongWordIds.length > 5 ? 5 : wrongWordIds.length,
              (index) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text('单词 ID: ${wrongWordIds[index]}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to word detail
                },
              ),
            ),
            if (wrongWordIds.length > 5)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '还有 ${wrongWordIds.length - 5} 个单词...',
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
        if (wrongCards > 0)
          OutlinedButton.icon(
            onPressed: () {
              // Navigate to error book review
              Navigator.of(context).popUntil((route) => route.isFirst);
              // TODO: Navigate to error book page
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
