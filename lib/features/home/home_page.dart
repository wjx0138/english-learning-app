import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outerConstraints) {
        // 根据屏幕宽度调整布局
        final isSmallScreen = outerConstraints.maxWidth < 600;
        final isMediumScreen = outerConstraints.maxWidth < 900 && outerConstraints.maxWidth >= 600;
        final isTabletScreen = outerConstraints.maxWidth >= 900 && outerConstraints.maxWidth < 1200; // iPad Pro
        final isLargeScreen = outerConstraints.maxWidth >= 1200; // PC端

        // iPad Pro 使用更紧凑的 AppBar
        final appBarHeight = isTabletScreen ? 48.0 : kToolbarHeight;

        return Scaffold(
          appBar: AppBar(
            toolbarHeight: appBarHeight,
            title: const Text('英语学习'),
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isSmallScreen ? 24 : (isTabletScreen ? 32 : 24)),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // iPad Pro：内容区域宽度限制为屏幕80%
                      if (isTabletScreen)
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
                          child: Column(
                            children: [
                              // 图标 - iPad Pro 使用较大尺寸
                              Icon(
                                Icons.school,
                                size: 72,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(height: 20),
                              // 主标题 - iPad Pro 使用较大字号
                              Text(
                                '欢迎使用英语学习App',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 12),
                              Text(
                                '基于FSRS间隔重复算法',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 18,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '高效记忆英语单词',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontSize: 18,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 32),
                              // 开始学习按钮 - iPad Pro 放大
                              ElevatedButton.icon(
                                onPressed: () {
                                  context.push('/flashcard');
                                },
                                icon: const Icon(Icons.play_arrow, size: 28),
                                label: const Text('开始学习', style: TextStyle(fontSize: 18)),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 48,
                                    vertical: 18,
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                  minimumSize: const Size(200, 60),
                                ),
                              ),
                              SizedBox(height: 16),
                              // 课程中心按钮 - iPad Pro 放大
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.push('/courses');
                                },
                                icon: const Icon(Icons.library_books, size: 24),
                                label: const Text('课程中心', style: TextStyle(fontSize: 17)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 16,
                                  ),
                                  minimumSize: const Size(200, 56),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          // 非iPad Pro保持原样
                          children: [
                            // 图标 - 其他屏幕
                            Icon(
                              Icons.school,
                              size: isSmallScreen ? 64 : (isLargeScreen ? 80 : 100),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            // 间距
                            SizedBox(height: isSmallScreen ? 16 : 24),
                            // 主标题
                            Text(
                              '欢迎使用英语学习App',
                              style: isSmallScreen
                                  ? Theme.of(context).textTheme.titleLarge
                                  : (isLargeScreen
                                      ? Theme.of(context).textTheme.titleLarge
                                      : Theme.of(context).textTheme.headlineMedium),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '基于FSRS间隔重复算法',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '高效记忆英语单词',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            // 间距
                            SizedBox(height: isSmallScreen ? 32 : 48),
                            // 开始学习按钮
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
                            SizedBox(height: isSmallScreen ? 16 : 16),
                            // 课程中心按钮
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
                          ],
                        ),
                      // 间距
                      SizedBox(height: isSmallScreen ? 24 : (isTabletScreen ? 24 : 32)),
                      // Feature cards - 响应式网格布局
                      _buildFeatureGrid(context, constraints, isSmallScreen, isMediumScreen, isLargeScreen, isTabletScreen),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureGrid(
    BuildContext context,
    BoxConstraints constraints,
    bool isSmallScreen,
    bool isMediumScreen,
    bool isLargeScreen,
    bool isTabletScreen,
  ) {
    final features = [
      {'icon': Icons.style, 'title': '智能卡片', 'subtitle': 'FSRS算法', 'route': '/flashcard'},
      {'icon': Icons.keyboard, 'title': '打字练习', 'subtitle': '肌肉记忆', 'route': '/typing'},
      {'icon': Icons.quiz, 'title': '选择题测试', 'subtitle': '知识检验', 'route': '/quiz'},
      {'icon': Icons.bar_chart, 'title': '学习统计', 'subtitle': '进度追踪', 'route': '/progress'},
      {'icon': Icons.error_outline, 'title': '错题本', 'subtitle': '重点复习', 'route': '/error-book'},
      {'icon': Icons.settings, 'title': '设置', 'subtitle': '个性化配置', 'route': '/settings'},
    ];

    // iPad Pro（900-1199px）：2×3布局，居中显示
    if (isTabletScreen) {
      final screenWidth = constraints.maxWidth;
      final maxGridWidth = (screenWidth * 0.6).clamp(520.0, 580.0);

      return Center(
        child: SizedBox(
          width: maxGridWidth,
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, // 2列
            mainAxisSpacing: 12, // 减小间距
            crossAxisSpacing: 12,
            childAspectRatio: 1.35, // 减少15%高度
            children: features.map((feature) {
              return _buildFeatureCard(
                context,
                feature['icon'] as IconData,
                feature['title'] as String,
                feature['subtitle'] as String,
                feature['route'] as String,
                isSmallScreen,
                isLargeScreen,
                isTabletScreen,
                false, // isMediumScreen
              );
            }).toList(),
          ),
        ),
      );
    }

    // PC端（≥1200px）：2×3布局，居中显示
    if (isLargeScreen) {
      final screenWidth = constraints.maxWidth;
      final maxGridWidth = (screenWidth * 0.4).clamp(500.0, 600.0);

      return Center(
        child: SizedBox(
          width: maxGridWidth,
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, // 2列
            mainAxisSpacing: 10, // 减小间距
            crossAxisSpacing: 10,
            childAspectRatio: 1.41, // 减少15%高度
            children: features.map((feature) {
              return _buildFeatureCard(
                context,
                feature['icon'] as IconData,
                feature['title'] as String,
                feature['subtitle'] as String,
                feature['route'] as String,
                isSmallScreen,
                isLargeScreen,
                false,
                false, // isMediumScreen
              );
            }).toList(),
          ),
        ),
      );
    }

    // iPad Air / iPad mini（600-899px）：2列布局，2个卡片总宽度占屏幕70%
    if (isMediumScreen) {
      final screenWidth = constraints.maxWidth;
      final maxGridWidth = screenWidth * 0.7; // 2个卡片总宽度占70%

      return Center(
        child: SizedBox(
          width: maxGridWidth,
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8, // 进一步减小间距
            crossAxisSpacing: 8,
            childAspectRatio: 1.18, // 减少15%高度
            children: features.map((feature) {
              return _buildFeatureCard(
                context,
                feature['icon'] as IconData,
                feature['title'] as String,
                feature['subtitle'] as String,
                feature['route'] as String,
                isSmallScreen,
                false,
                false,
                true, // isMediumScreen
              );
            }).toList(),
          ),
        ),
      );
    }

    // 移动端：统一使用2列
    final crossAxisCount = 2;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: isSmallScreen ? 8 : 10, // 进一步减小间距
      crossAxisSpacing: isSmallScreen ? 8 : 10,
      childAspectRatio: isSmallScreen ? 1.24 : 1.29, // 减少15%高度
      children: features.map((feature) {
        return _buildFeatureCard(
          context,
          feature['icon'] as IconData,
          feature['title'] as String,
          feature['subtitle'] as String,
          feature['route'] as String,
          isSmallScreen,
          false,
          false,
          false, // isMediumScreen
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
    bool isLargeScreen,
    bool isTabletScreen,
    bool isMediumScreen,
  ) {
    return InkWell(
      onTap: () {
        context.push(route);
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 10 : (isTabletScreen ? 16 : (isLargeScreen ? 12 : (isMediumScreen ? 10 : 16)))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSmallScreen ? 28 : (isTabletScreen ? 40 : (isLargeScreen ? 26 : (isMediumScreen ? 32 : 32))),
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: isSmallScreen ? 4 : (isTabletScreen ? 8 : (isLargeScreen ? 4 : (isMediumScreen ? 4 : 8)))),
              Text(
                title,
                style: isSmallScreen
                    ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14, // 移动端减小
                          height: 1.0,
                        )
                    : (isTabletScreen
                        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              height: 1.0,
                            )
                        : (isLargeScreen
                            ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  height: 1.0,
                                )
                            : (isMediumScreen
                                ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17, // iPad Air 减小
                                      height: 1.0,
                                    )
                                : Theme.of(context).textTheme.titleSmall?.copyWith(
                                      height: 1.0,
                                    )))),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (!isSmallScreen)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: isTabletScreen ? 16 : (isLargeScreen ? 11 : (isMediumScreen ? 14 : null)),
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
                        fontSize: 11, // 移动端减小
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
