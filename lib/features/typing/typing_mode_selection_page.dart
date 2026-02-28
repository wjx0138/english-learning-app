import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/word.dart';
import '../../data/models/typing_practice.dart';
import '../../core/providers/app_provider.dart';
import '../vocabulary/vocabulary_selection_page.dart';
import 'typing_practice_page.dart';
import 'typing_settings_page.dart';

/// Typing Practice Mode Selection Page
class TypingModeSelectionPage extends StatelessWidget {
  const TypingModeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final words = context.watch<AppProvider>().words;

    return Scaffold(
      appBar: AppBar(
        title: const Text('打字练习'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TypingSettingsPage(),
                ),
              );
            },
            tooltip: '设置',
          ),
        ],
      ),
      body: words.isEmpty
          ? _buildEmptyState(context)
          : _buildModeSelection(context, words),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            '请先选择词库',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VocabularySelectionPage(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('选择词库'),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelection(BuildContext context, List<Word> words) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Word count info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Icon(
                    Icons.library_books,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '当前词库',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${words.length} 个单词',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const VocabularySelectionPage(),
                        ),
                      );
                    },
                    tooltip: '更换词库',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mode selection title
          Text(
            '选择练习模式',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Visible mode card
          _buildModeCard(
            context,
            title: '跟打模式',
            description: '看着单词练习打字，熟悉键盘布局',
            icon: Icons.visibility,
            color: Colors.blue,
            mode: TypingMode.visible,
            words: words,
          ),
          const SizedBox(height: 16),

          // Dictation mode card
          _buildModeCard(
            context,
            title: '听写模式',
            description: '听发音拼写单词，加强记忆',
            icon: Icons.hearing,
            color: Colors.green,
            mode: TypingMode.dictation,
            words: words,
          ),
          const SizedBox(height: 24),

          // Quick practice button
          OutlinedButton.icon(
            onPressed: () {
              _startQuickPractice(context, words);
            },
            icon: const Icon(Icons.shuffle),
            label: const Text('随机练习 10 个单词'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required TypingMode mode,
    required List<Word> words,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TypingPracticePage(
                words: words,
                initialMode: mode,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuickPractice(BuildContext context, List<Word> words) {
    // Shuffle and take first 10
    final shuffled = List<Word>.from(words)..shuffle();
    final practiceWords = shuffled.take(10).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TypingPracticePage(
          words: practiceWords,
          initialMode: TypingMode.visible,
        ),
      ),
    );
  }
}
