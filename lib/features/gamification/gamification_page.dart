import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/gamification.dart';
import '../../core/providers/app_provider.dart';
import '../../shared/services/gamification_service.dart';
import '../../shared/services/share_service.dart';

/// 游戏化页面 - 显示等级、积分和成就
class GamificationPage extends StatefulWidget {
  const GamificationPage({super.key});

  @override
  State<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends State<GamificationPage> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (mounted) {
      context.read<AppProvider>().refreshGameData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('成就与等级'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareProgress(context),
            tooltip: '分享进度',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          final gameData = appProvider.gameData;

          if (gameData == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 等级卡片
                _buildLevelCard(context, gameData),

                const SizedBox(height: 20),

                // 统计卡片
                _buildStatsCards(context, gameData),

                const SizedBox(height: 20),

                // 连续打卡
                _buildStreakCard(context, gameData),

                const SizedBox(height: 20),

                // 成就列表
                _buildAchievementsSection(context, gameData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, UserGameData gameData) {
    final levelColor = UserGameData.getLevelColor(gameData.level);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            levelColor,
            levelColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: levelColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lv.${gameData.level}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    gameData.levelTitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      '总积分',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${gameData.totalPoints}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 进度条
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '下一等级',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${gameData.currentLevelPoints}/${gameData.nextLevelPoints}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: gameData.levelProgress,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, UserGameData gameData) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            Icons.calendar_today,
            '学习天数',
            '${gameData.totalStudyDays}',
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            Icons.book,
            '学习单词',
            '${gameData.stats['wordsLearned'] ?? 0}',
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            Icons.schedule,
            '学习时长',
            _formatMinutes(gameData.stats['practiceMinutes'] ?? 0),
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, UserGameData gameData) {
    if (gameData.streak == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department,
                color: Colors.orange.shade700,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '连续学习',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '已连续 ${gameData.streak} 天',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: List.generate(
                gameData.streak.clamp(1, 7),
                (index) => const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.whatshot,
                    color: Colors.orange,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(
    BuildContext context,
    UserGameData gameData,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '成就',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '${gameData.unlockedAchievements.length}/${Achievements.getAllAchievements().length}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Achievement>>(
          future: GamificationService.getAllAchievements(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final achievements = snapshot.data!;

            if (achievements.isEmpty) {
              return const Center(
                child: Text('暂无成就'),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                return _buildAchievementCard(achievements[index]);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;

    return InkWell(
      onTap: isUnlocked
          ? () => _shareAchievement(context, achievement)
          : null,
      child: Container(
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  colors: [
                    Colors.amber.shade400,
                    Colors.amber.shade600,
                  ],
                )
              : null,
          color: isUnlocked ? null : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: isUnlocked
              ? null
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    achievement.icon,
                    color: isUnlocked ? Colors.white : Colors.grey.shade400,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement.title,
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+${achievement.points}',
                    style: TextStyle(
                      color: isUnlocked ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              if (isUnlocked)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.share,
                      size: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareProgress(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final gameData = appProvider.gameData;

    if (gameData == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('分享进度'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('学习进度报告'),
              onTap: () {
                Navigator.of(context).pop();
                ShareService.shareProgressReport(
                  level: gameData.level,
                  levelTitle: gameData.levelTitle,
                  totalPoints: gameData.totalPoints,
                  streak: gameData.streak,
                  totalStudyDays: gameData.totalStudyDays,
                  wordsLearned: gameData.stats['wordsLearned'] ?? 0,
                  practiceMinutes: gameData.stats['practiceMinutes'] ?? 0,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.military_tech),
              title: const Text('等级成就'),
              onTap: () {
                Navigator.of(context).pop();
                ShareService.shareLevelUp(
                  gameData.level,
                  gameData.levelTitle,
                  gameData.totalPoints,
                );
              },
            ),
            if (gameData.streak >= 3)
              ListTile(
                leading: const Icon(Icons.local_fire_department),
                title: const Text('连续打卡'),
                onTap: () {
                  Navigator.of(context).pop();
                  ShareService.shareStreak(
                    gameData.streak,
                    gameData.totalStudyDays,
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.campaign),
              title: const Text('推荐应用'),
              onTap: () {
                Navigator.of(context).pop();
                ShareService.shareApp();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _shareAchievement(BuildContext context, Achievement achievement) {
    ShareService.shareAchievement(achievement);
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes分钟';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours小时';
    }
    return '$hours小时$mins分';
  }
}
