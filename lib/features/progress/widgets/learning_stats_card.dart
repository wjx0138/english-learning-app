import 'package:flutter/material.dart';

/// Learning Statistics Card Widget
class LearningStatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;

  const LearningStatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (iconColor ?? Theme.of(context).colorScheme.primary)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: iconColor ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: backgroundColor != null
                              ? Colors.white
                              : null,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: backgroundColor != null
                              ? Colors.white70
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Learning Stats Grid Widget
class LearningStatsGrid extends StatelessWidget {
  final int totalWords;
  final int wordsLearned;
  final int studyStreak;
  final Duration totalStudyTime;

  const LearningStatsGrid({
    super.key,
    required this.totalWords,
    required this.wordsLearned,
    required this.studyStreak,
    required this.totalStudyTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '学习统计',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            LearningStatsCard(
              title: '总词汇量',
              value: '$totalWords',
              subtitle: '已加载',
              icon: Icons.library_books,
              iconColor: Colors.blue,
            ),
            LearningStatsCard(
              title: '已学习',
              value: '$wordsLearned',
              subtitle: '个单词',
              icon: Icons.check_circle,
              iconColor: Colors.green,
            ),
            LearningStatsCard(
              title: '连续打卡',
              value: '$studyStreak',
              subtitle: '天',
              icon: Icons.local_fire_department,
              iconColor: Colors.orange,
            ),
            LearningStatsCard(
              title: '学习时长',
              value: _formatDuration(totalStudyTime),
              subtitle: '总计',
              icon: Icons.access_time,
              iconColor: Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '0m';
    }
  }
}
