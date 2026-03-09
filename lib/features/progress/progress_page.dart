import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/progress_provider.dart';
import '../../core/providers/app_provider.dart';
import 'widgets/learning_stats_card.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  @override
  void initState() {
    super.initState();
    // Initialize progress data on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习统计'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Consumer<ProgressProvider>(
        builder: (context, progressProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Daily goal progress
                _buildDailyGoalSection(context, progressProvider),
                const SizedBox(height: 24),

                // Vocabulary progress
                _buildVocabularyProgressSection(context, progressProvider),
                const SizedBox(height: 24),

                // Statistics overview cards
                _buildStatisticsSection(context, progressProvider),
                const SizedBox(height: 24),

                // Learning statistics cards
                _buildLearningStatsCards(context),
                const SizedBox(height: 24),

                // Reset button (for testing)
                _buildResetButton(context, progressProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyGoalSection(
    BuildContext context,
    ProgressProvider provider,
  ) {
    final dailyGoal = provider.dailyGoal;
    final todayCards = provider.todayStudied; // 使用 todayStudied 而不是 weeklyStudyData
    final progress = dailyGoal > 0 ? (todayCards / dailyGoal).clamp(0.0, 1.0) : 0.0;
    final percentage = dailyGoal > 0 ? (progress * 100).toInt() : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Circular progress indicator
            SizedBox(
              width: 100,
              height: 100,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? Colors.green : Colors.blue,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percentage%',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: progress >= 1.0 ? Colors.green : Colors.blue,
                            ),
                      ),
                      Text(
                        '今日目标',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Goal details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '每日学习目标',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showGoalSettingsDialog(context, provider),
                        tooltip: '修改目标',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '今日已学习 $todayCards / $dailyGoal 张卡片',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (progress >= 1.0)
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '目标已完成！',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      '还差 ${dailyGoal - todayCards} 张卡片',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalSettingsDialog(BuildContext context, ProgressProvider provider) {
    final controller = TextEditingController(text: provider.dailyGoal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('设置每日目标'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '设置每天想学习的卡片数量（5-100张）',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '每日目标',
                suffixText: '张',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [10, 20, 30, 50, 100].map((goal) {
                return ActionChip(
                  label: Text('$goal张'),
                  onPressed: () {
                    controller.text = goal.toString();
                  },
                  backgroundColor: provider.dailyGoal == goal
                      ? Theme.of(context).colorScheme.primaryContainer
                      : null,
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final newGoal = int.tryParse(controller.text);
              if (newGoal != null && newGoal >= 5 && newGoal <= 100) {
                provider.setDailyGoal(newGoal);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('每日目标已设置为 $newGoal 张')),
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyProgressSection(
    BuildContext context,
    ProgressProvider provider,
  ) {
    final appProvider = Provider.of<AppProvider>(context);
    final learnedCount = provider.learnedVocabularyCount;
    final totalCount = appProvider.words.length;
    final progress = totalCount > 0 ? learnedCount / totalCount : 0.0;
    final percentage = (progress * 100).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '词汇量进度',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Chip(
                  label: Text('$percentage%'),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '选择题或听写练习答对2次即可掌握',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '已掌握 $learnedCount 个单词',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                ),
                Text(
                  '总共 $totalCount 个单词',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    ProgressProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '学习概况',
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
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildStatCard(
                  context,
                  '总学习天数',
                  '${provider.totalStudyDays}',
                  Icons.calendar_today,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  '今日学习',
                  '${provider.todayStudied}',
                  Icons.style,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  '当前连续',
                  '${provider.currentStreak} 天',
                  Icons.local_fire_department,
                  Colors.red,
                ),
                _buildStatCard(
                  context,
                  '最长连续',
                  '${provider.longestStreak} 天',
                  Icons.emoji_events,
                  Colors.purple,
                ),
              ],
            );
          },
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
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 根据卡片宽度调整布局
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
                Icon(icon, color: color, size: iconSize),
                SizedBox(height: spacing),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: valueFontSize,
                        height: 1.0,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: smallSpacing),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
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

  Widget _buildLearningStatsCards(BuildContext context) {
    final progressProvider = Provider.of<ProgressProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);

    // 使用真实数据而不是Mock数据
    final totalWords = appProvider.words.length;
    final wordsLearned = progressProvider.learnedVocabularyCount;
    final todayStudyMinutes = progressProvider.todayStudyMinutes;
    final totalStudyTime = Duration(minutes: progressProvider.totalStudyMinutes ?? 0);

    return LearningStatsGrid(
      totalWords: totalWords,
      wordsLearned: wordsLearned,
      todayStudyMinutes: todayStudyMinutes,
      totalStudyTime: totalStudyTime,
    );
  }

  Widget _buildResetButton(
    BuildContext context,
    ProgressProvider provider,
  ) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('重置进度'),
              content: const Text('确定要重置所有学习进度吗？此操作不可恢复。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    provider.resetProgress();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('进度已重置')),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('确定'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Icons.refresh),
        label: const Text('重置进度（测试用）'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.grey[600],
        ),
      ),
    );
  }
}
