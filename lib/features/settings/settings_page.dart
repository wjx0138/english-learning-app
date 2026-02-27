import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../shared/services/tts_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TTSService _ttsService = TTSService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: ListView(
        children: [
          _buildSectionHeader('学习设置'),
          _buildDailyGoalCard(),
          const SizedBox(height: 8),
          _buildSectionHeader('语音设置'),
          _buildTTSCard(),
          const SizedBox(height: 8),
          _buildSectionHeader('数据管理'),
          _buildDataManagementCard(),
          const SizedBox(height: 8),
          _buildSectionHeader('关于'),
          _buildAboutCard(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildDailyGoalCard() {
    return Consumer<ProgressProvider>(
      builder: (context, provider, _) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.flag,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '每日学习目标',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '当前目标：${provider.dailyGoal} 张卡片/天',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showGoalSettingsDialog(context, provider),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('设置每天想学习的卡片数量，建议根据个人情况选择合适的难度。'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTTSCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.volume_up,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '语音设置',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        _ttsService.currentAccent,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _ttsService.isSupported,
                  onChanged: (value) {
                    if (!value) {
                      _showTTSDialog(context);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('切换口音'),
              subtitle: Text(_ttsService.currentAccent),
              trailing: TextButton(
                onPressed: () {
                  _ttsService.toggleAccent();
                  setState(() {});
                },
                child: const Text('切换'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.storage,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Text(
                  '数据管理',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.orange),
              title: const Text('重置学习进度'),
              subtitle: const Text('清除所有学习统计数据，包括成就和连续记录'),
              onTap: () => _showResetProgressDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '关于应用',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '版本 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('基于FSRS间隔重复算法的英语学习应用'),
            const SizedBox(height: 8),
            const Text('© 2025 English Learning App'),
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

  void _showTTSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('语音功能'),
        content: const Text('您的设备不支持TTS语音功能，无法切换开关。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  void _showResetProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置学习进度'),
        content: const Text('确定要清除所有学习统计数据吗？此操作不可恢复。\n\n将清除：\n• 学习天数和卡片数\n• 正确率和连续记录\n• 成就徽章\n• 词汇掌握进度'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<ProgressProvider>().resetProgress();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('学习进度已重置')),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('确定重置'),
          ),
        ],
      ),
    );
  }
}
