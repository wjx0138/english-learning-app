import 'package:flutter/material.dart';
import '../../../data/models/typing_practice.dart';

/// Real-time Typing Statistics Display
class TypingStatsWidget extends StatelessWidget {
  final int wordsCompleted;
  final int wordsCorrect;
  final int wordsWrong;
  final int wordsRemaining;
  final double accuracy;
  final double cpm; // Characters per minute
  final int totalDurationSeconds;

  const TypingStatsWidget({
    super.key,
    required this.wordsCompleted,
    required this.wordsCorrect,
    required this.wordsWrong,
    required this.wordsRemaining,
    required this.accuracy,
    required this.cpm,
    this.totalDurationSeconds = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress bar
            _buildProgressBar(context),
            const SizedBox(height: 24),

            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildStatCard(
                  context,
                  '已完成',
                  '$wordsCompleted',
                  Icons.check_circle_outline,
                  Colors.blue,
                  '个单词',
                ),
                _buildStatCard(
                  context,
                  '正确',
                  '$wordsCorrect',
                  Icons.done,
                  Colors.green,
                  '个',
                ),
                _buildStatCard(
                  context,
                  '错误',
                  '$wordsWrong',
                  Icons.close,
                  Colors.red,
                  '个',
                ),
                _buildStatCard(
                  context,
                  '剩余',
                  '$wordsRemaining',
                  Icons.pending,
                  Colors.orange,
                  '个',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Detailed stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailStat(
                  context,
                  '正确率',
                  '${accuracy.toStringAsFixed(1)}%',
                  Icons.percent,
                  accuracy >= 80
                      ? Colors.green
                      : accuracy >= 60
                          ? Colors.orange
                          : Colors.red,
                ),
                _buildDetailStat(
                  context,
                  '打字速度',
                  '${cpm.toStringAsFixed(0)} CPM',
                  Icons.speed,
                  Colors.purple,
                ),
                if (totalDurationSeconds > 0)
                  _buildDetailStat(
                    context,
                    '耗时',
                    _formatDuration(totalDurationSeconds),
                    Icons.timer,
                    Colors.teal,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final totalWords = wordsCompleted + wordsRemaining;
    final progress = totalWords > 0 ? wordsCompleted / totalWords : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '练习进度',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '$wordsCompleted / $totalWords',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : Colors.blue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
    String suffix,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 2),
          Text(
            suffix,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color.withOpacity(0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }
}

/// Compact version for inline display
class CompactTypingStats extends StatelessWidget {
  final int correct;
  final int total;
  final double cpm;

  const CompactTypingStats({
    super.key,
    required this.correct,
    required this.total,
    required this.cpm,
  });

  @override
  Widget build(BuildContext context) {
    final accuracy = total > 0 ? (correct / total * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactStat(
            context,
            Icons.check_circle,
            correct,
            total,
            accuracy >= 80 ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 16),
          _buildCompactStat(
            context,
            Icons.speed,
            cpm.toInt(),
            null,
            Colors.purple,
            suffix: ' CPM',
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStat(
    BuildContext context,
    IconData icon,
    int value,
    int? total,
    Color color, {
    String? suffix,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          total != null ? '$value/$total' : '$value$suffix',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }
}
