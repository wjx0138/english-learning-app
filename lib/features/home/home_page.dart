import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('英语学习'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 根据屏幕宽度调整布局
              final isSmallScreen = constraints.maxWidth < 600;
              final isMediumScreen = constraints.maxWidth < 900;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school,
                    size: isSmallScreen ? 64 : 100,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 24),
                  Text(
                    '欢迎使用英语学习App',
                    style: isSmallScreen
                        ? Theme.of(context).textTheme.titleLarge
                        : Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '基于FSRS间隔重复算法',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '高效记忆英语单词',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallScreen ? 32 : 48),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.push('/flashcard');
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('开始学习'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 24 : 32,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: Size(
                        isSmallScreen ? 0 : 200,
                        isSmallScreen ? 48 : 56,
                      ),
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
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 24 : 32,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      minimumSize: Size(
                        isSmallScreen ? 0 : 200,
                        isSmallScreen ? 48 : 56,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 24 : 32),
                  // Feature cards - 响应式网格布局
                  _buildFeatureGrid(context, isSmallScreen, isMediumScreen),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, bool isSmallScreen, bool isMediumScreen) {
    // 根据屏幕宽度确定列数
    final crossAxisCount = isSmallScreen ? 2 : (isMediumScreen ? 3 : 3);
    final features = [
      {'icon': Icons.style, 'title': '智能卡片', 'subtitle': 'FSRS算法', 'route': '/flashcard'},
      {'icon': Icons.keyboard, 'title': '打字练习', 'subtitle': '肌肉记忆', 'route': '/typing'},
      {'icon': Icons.quiz, 'title': '选择题测试', 'subtitle': '知识检验', 'route': '/quiz'},
      {'icon': Icons.bar_chart, 'title': '学习统计', 'subtitle': '进度追踪', 'route': '/progress'},
      {'icon': Icons.error_outline, 'title': '错题本', 'subtitle': '重点复习', 'route': '/error-book'},
      {'icon': Icons.settings, 'title': '设置', 'subtitle': '个性化配置', 'route': '/settings'},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: isSmallScreen ? 12 : 16,
      crossAxisSpacing: isSmallScreen ? 12 : 16,
      childAspectRatio: isSmallScreen ? 1.3 : 1.33,
      children: features.map((feature) {
        return _buildFeatureCard(
          context,
          feature['icon'] as IconData,
          feature['title'] as String,
          feature['subtitle'] as String,
          feature['route'] as String,
          isSmallScreen,
        );
      }).toList(),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    String route,
    bool isSmallScreen,
  ) {
    return InkWell(
      onTap: () {
        context.push(route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSmallScreen ? 30 : 32,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                title,
                style: isSmallScreen
                    ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.0,
                        )
                    : Theme.of(context).textTheme.titleSmall?.copyWith(
                          height: 1.0,
                        ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isSmallScreen)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.0,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        height: 1.0,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
