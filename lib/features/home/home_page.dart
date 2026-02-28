import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/level_indicator.dart';
import '../../core/providers/app_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('英语学习'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          const LevelIndicator(showPoints: true),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.school,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                '欢迎使用英语学习App',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '基于FSRS间隔重复算法',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '高效记忆英语单词',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/flashcard');
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('开始学习'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size(200, 56),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  context.push('/courses');
                },
                icon: const Icon(Icons.library_books),
                label: const Text('课程中心'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  minimumSize: const Size(200, 56),
                ),
              ),
              const SizedBox(height: 32),
              // Feature cards - 2x2 grid
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureCard(
                        context,
                        Icons.style,
                        '智能卡片',
                        'FSRS算法',
                        '/flashcard',
                      ),
                      const SizedBox(width: 16),
                      _buildFeatureCard(
                        context,
                        Icons.keyboard,
                        '打字练习',
                        '肌肉记忆',
                        '/typing',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureCard(
                        context,
                        Icons.quiz,
                        '选择题测试',
                        '知识检验',
                        '/quiz',
                      ),
                      const SizedBox(width: 16),
                      _buildFeatureCard(
                        context,
                        Icons.bar_chart,
                        '学习统计',
                        '进度追踪',
                        '/progress',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureCard(
                        context,
                        Icons.error_outline,
                        '错题本',
                        '重点复习',
                        '/error-book',
                      ),
                      const SizedBox(width: 16),
                      _buildFeatureCard(
                        context,
                        Icons.class_,
                        '课程中心',
                        '分类学习',
                        '/courses',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureCard(
                        context,
                        Icons.menu_book,
                        '词汇列表',
                        '查看单词',
                        '/vocabulary',
                      ),
                      const SizedBox(width: 16),
                      _buildFeatureCard(
                        context,
                        Icons.settings,
                        '设置',
                        '个性化配置',
                        '/settings',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String route,
  ) {
    return InkWell(
      onTap: () {
        context.push(route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
