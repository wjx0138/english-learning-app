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
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据卡片宽度调整布局（与学习概况卡片一致）
        final isSmall = constraints.maxWidth < 120;
        final padding = isSmall ? 6.0 : 16.0;
        final iconSize = isSmall ? 18.0 : 28.0;
        final valueFontSize = isSmall ? 13.0 : 24.0;
        final labelFontSize = isSmall ? 9.0 : 12.0;
        final spacing = isSmall ? 3.0 : 8.0;
        final smallSpacing = isSmall ? 1.0 : 4.0;

        return Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                  size: iconSize,
                ),
                SizedBox(height: spacing),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: iconColor ?? Theme.of(context).colorScheme.primary,
                        fontSize: valueFontSize,
                        height: 1.0,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: smallSpacing),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontSize: labelFontSize,
                        height: 1.0,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                          fontSize: labelFontSize,
                          height: 1.0,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Learning Stats Grid Widget
class LearningStatsGrid extends StatelessWidget {
  final int totalWords;
  final int wordsLearned;
  final int todayStudyMinutes;
  final Duration totalStudyTime;

  const LearningStatsGrid({
    super.key,
    required this.totalWords,
    required this.wordsLearned,
    required this.todayStudyMinutes,
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
        LayoutBuilder(
          builder: (context, constraints) {
            // 移动端2×2，PC端和平板端1×4
            final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                LearningStatsCard(
                  title: '总词汇量',
                  value: '$totalWords',
                  subtitle: '',
                  icon: Icons.library_books,
                  iconColor: Colors.blue,
                ),
                LearningStatsCard(
                  title: '已学习',
                  value: '$wordsLearned',
                  subtitle: '',
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                ),
                LearningStatsCard(
                  title: '今日时长',
                  value: _formatDuration(Duration(minutes: todayStudyMinutes)),
                  subtitle: '',
                  icon: Icons.access_time,
                  iconColor: Colors.orange,
                ),
                LearningStatsCard(
                  title: '总学习时长',
                  value: _formatDuration(totalStudyTime),
                  subtitle: '',
                  icon: Icons.schedule,
                  iconColor: Colors.purple,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours > 0) {
      return '${hours}h${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m';
    } else {
      return '0m';
    }
  }
}
