import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/providers/progress_provider.dart';
import '../../data/models/learning_data.dart';
import '../../shared/services/chart_data_service.dart';
import 'widgets/learning_curve_chart.dart';
import 'widgets/vocabulary_growth_chart.dart';
import 'widgets/learning_stats_card.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  // Mock data for charts (will be replaced with real data later)
  late List<LearningData> _learningData;
  late List<VocabularyGrowthData> _vocabularyGrowthData;

  @override
  void initState() {
    super.initState();
    // Initialize progress data on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().initialize();
    });

    // Generate mock data for charts
    _learningData = ChartDataService.generateMockLearningData();
    _vocabularyGrowthData = ChartDataService.generateMockVocabularyGrowthData();
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

                // Weekly study chart
                _buildWeeklyChart(context, progressProvider),
                const SizedBox(height: 24),

                // Learning statistics cards
                _buildLearningStatsCards(context),
                const SizedBox(height: 24),

                // Learning curve chart
                LearningCurveChart(data: _learningData),
                const SizedBox(height: 24),

                // Vocabulary growth chart
                VocabularyGrowthChart(data: _vocabularyGrowthData),
                const SizedBox(height: 24),

                // Achievements section
                _buildAchievementsSection(context, progressProvider),
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
    final todayCards = provider.weeklyStudyData[DateTime.now().weekday - 1] ?? 0;
    final progress = (todayCards / dailyGoal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

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
    final learnedCount = provider.learnedVocabularyCount;
    final totalCount = provider.totalVocabularySize;
    final progress = provider.vocabularyProgress;
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
              '需连续答对3次才算掌握',
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
        GridView.count(
          crossAxisCount: 2,
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
              '学习卡片',
              '${provider.totalCardsStudied}',
              Icons.style,
              Colors.green,
            ),
            _buildStatCard(
              context,
              '正确率',
              '${(provider.overallAccuracy * 100).toStringAsFixed(1)}%',
              Icons.check_circle,
              Colors.orange,
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
            _buildStatCard(
              context,
              '正确/错误',
              '${provider.totalCorrectAnswers}/${provider.totalWrongAnswers}',
              Icons.compare_arrows,
              Colors.teal,
            ),
          ],
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
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

  Widget _buildWeeklyChart(
    BuildContext context,
    ProgressProvider provider,
  ) {
    final weeklyData = provider.weeklyStudyData;
    final maxValue = weeklyData.values.isEmpty
        ? 1
        : weeklyData.values.reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '本周学习趋势',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(7, (index) {
                  final value = weeklyData[index] ?? 0;
                  final height = maxValue > 0 ? (value / maxValue) * 120 : 0;
                  final days = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 32,
                        height: height.toDouble(),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        value.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        days[index],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningStatsCards(BuildContext context) {
    // Calculate statistics from mock data
    final totalStudyTime = ChartDataService.calculateTotalStudyTime(_learningData);
    final weeklySummary = ChartDataService.getWeeklySummary(_learningData);
    final todayStats = ChartDataService.getTodayStats(_learningData);
    final totalWords = _vocabularyGrowthData.isNotEmpty
        ? _vocabularyGrowthData.last.totalWords
        : 0;

    return LearningStatsGrid(
      totalWords: totalWords,
      wordsLearned: weeklySummary['totalWords'] as int,
      studyStreak: Provider.of<ProgressProvider>(context).currentStreak,
      totalStudyTime: totalStudyTime,
    );
  }

  Widget _buildAchievementsSection(
    BuildContext context,
    ProgressProvider provider,
  ) {
    final achievements = provider.achievements;
    final unlockedCount =
        achievements.where((a) => a.isUnlocked).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '成就徽章',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Chip(
              label: Text('$unlockedCount/${achievements.length}'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return _buildAchievementCard(context, achievement);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    Achievement achievement,
  ) {
    final isUnlocked = achievement.isUnlocked;

    return Card(
      elevation: isUnlocked ? 2 : 0.5,
      color: isUnlocked ? null : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  achievement.icon,
                  color: isUnlocked
                      ? Colors.amber
                      : Colors.grey,
                  size: 24,
                ),
                const Spacer(),
                if (isUnlocked)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              achievement.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? null : Colors.grey[600],
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: achievement.progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked ? Colors.green : Colors.grey,
              ),
            ),
          ],
        ),
      ),
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
