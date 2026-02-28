import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/gamification.dart';

/// 分享服务 - 分享学习成就和进度
class ShareService {
  /// 分享学习成就
  static Future<void> shareAchievement(Achievement achievement) async {
    final text = '''
🎉 我解锁了新成就！

🏆 ${achievement.title}
${achievement.description}
✨ 获得了 ${achievement.points} 积分！

我在用英语学习APP，一起来挑战吧！
#英语学习 #成就解锁
''';
    await Share.share(text, subject: '解锁成就：${achievement.title}');
  }

  /// 分享等级提升
  static Future<void> shareLevelUp(int level, String levelTitle, int totalPoints) async {
    final text = '''
🎊 我的英语水平提升了！

📈 等级：Lv.$level
🎖️ 称号：$levelTitle
💪 积分：$totalPoints

继续坚持，每天进步一点点！
#英语学习 #等级提升
''';
    await Share.share(text, subject: '升级到 Lv.$level');
  }

  /// 分享连续打卡记录
  static Future<void> shareStreak(int streak, int totalStudyDays) async {
    final text = '''
🔥 我已经连续学习 $streak 天了！

📚 累计学习：$totalStudyDays 天
💪 每天坚持，积少成多！

我在用英语学习APP，一起来打卡吧！
#英语学习 #连续打卡
''';
    await Share.share(text, subject: '连续打卡 $streak 天');
  }

  /// 分享学习进度报告
  static Future<void> shareProgressReport({
    required int level,
    required String levelTitle,
    required int totalPoints,
    required int streak,
    required int totalStudyDays,
    required int wordsLearned,
    required int practiceMinutes,
  }) async {
    final hours = (practiceMinutes / 60).toStringAsFixed(1);

    final text = '''
📊 我的学习进度报告

📖 等级：Lv.$level $levelTitle
💯 积分：$totalPoints
🔥 连续：$streak 天
📚 学习：$totalStudyDays 天
📝 词汇：$wordsLearned 词
⏰ 时长：$hours 小时

坚持学习，每天进步！
#英语学习 #学习报告
''';
    await Share.share(text, subject: '学习进度报告');
  }

  /// 分享词汇详情
  static Future<void> shareWord({
    required String word,
    required String? phonetic,
    required String definition,
    String? example,
  }) async {
    final text = '''
📝 今日单词：$word
$phonetic

$definition

${example ?? ''}

#英语单词 #每日一词
''';
    await Share.share(text, subject: '学习单词：$word');
  }

  /// 分享应用
  static Future<void> shareApp() async {
    final text = '''
🌟 推荐一个超棒的英语学习APP！

✨ 特色功能：
• 智能卡片学习（间隔重复算法）
• 打字练习（跟打+听写）
• 选择题测验（5种题型）
• 游戏化系统（积分+等级+成就）
• 词根词缀深度分析

📚 科学记忆，高效学习，每天进步一点点！

#英语学习 #背单词 #间隔重复
''';
    await Share.share(text, subject: '推荐英语学习APP');
  }

  /// 生成分享卡片（Widget形式，用于截图分享）
  static Widget generateShareCard({
    required String title,
    required String subtitle,
    required String stats,
    required IconData icon,
  }) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.white),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              stats,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '英语学习APP',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
