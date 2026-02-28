import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/gamification.dart';
import '../../core/providers/app_provider.dart';

/// 等级显示组件 - 显示在AppBar中
class LevelIndicator extends StatelessWidget {
  final bool showPoints;

  const LevelIndicator({
    super.key,
    this.showPoints = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final gameData = appProvider.gameData;
        if (gameData == null) {
          return const SizedBox.shrink();
        }

        final levelColor = UserGameData.getLevelColor(gameData.level);

        return InkWell(
          onTap: () {
            // 导航到游戏化页面
            Navigator.of(context).pushNamed('/gamification');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  levelColor.withOpacity(0.2),
                  levelColor.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: levelColor.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.military_tech,
                  color: levelColor,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Lv.${gameData.level}',
                  style: TextStyle(
                    color: levelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (showPoints) ...[
                  const SizedBox(width: 4),
                  Text(
                    '(${gameData.totalPoints})',
                    style: TextStyle(
                      color: levelColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
