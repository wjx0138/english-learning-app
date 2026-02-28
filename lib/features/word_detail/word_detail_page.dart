import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../data/models/word.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../shared/services/tts_service.dart';
import '../../../shared/services/etymology_service.dart';

/// Word Detail Page
class WordDetailPage extends StatefulWidget {
  final String wordId;
  final bool showBack;

  const WordDetailPage({
    super.key,
    required this.wordId,
    this.showBack = false,
  });

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  Word? _word;
  bool _isLoading = true;
  bool _isPlaying = false;
  final TTSService _ttsService = TTSService();

  @override
  void initState() {
    super.initState();
    _loadWord();
  }

  Future<void> _loadWord() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/cet4_words.json');
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final allWords = jsonList.map((json) => Word.fromJson(json as Map<String, dynamic>)).toList();

      // Find the word by ID
      setState(() {
        _word = allWords.firstWhere((w) => w.id == widget.wordId);
        _isLoading = false;
      });
    } catch (e) {
      // ignore: avoid_print
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _playPronunciation([String? text]) async {
    if (_isPlaying || _word == null) return;

    setState(() {
      _isPlaying = true;
    });

    try {
      await _ttsService.speak(text ?? _word!.word);
    } catch (e) {
      // Ignore errors
    }

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_word == null) {
      return _buildErrorState();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('词汇详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_word!.synonyms != null && _word!.synonyms!.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.format_list_bulleted),
              onPressed: () {
                _showSynonymsDialog(context);
              },
              tooltip: '同义词',
            ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _playPronunciation,
            tooltip: '播放发音',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word header
            _buildWordHeader(context),

            const SizedBox(height: 24),

            // Phonetic
            if (_word!.phonetic != null)
              _buildPhoneticCard(context),

            const SizedBox(height: 24),

            // Definition
            _buildDefinitionCard(context),

            const SizedBox(height: 24),

            // Examples
            if (_word!.examples != null && _word!.examples!.isNotEmpty)
              _buildExamplesCard(context),

            const SizedBox(height: 24),

            // Etymology (Word Roots & Affixes)
            _buildEtymologyCard(context),

            const SizedBox(height: 24),

            // Audio player
            _buildAudioControl(context),

            const SizedBox(height: 32),

            // Example sentence
            _buildExampleSentenceCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('词汇详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('加载中...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('词汇详情'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              '单词未找到',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _word!.word,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(width: 16),
              Chip(
                label: Text(_getDifficultyLabel(_word!.difficulty)),
                backgroundColor: Colors.white24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.bookmark_border,
                color: Colors.white70,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '收藏',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneticCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.record_voice_over,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '发音',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                _word!.phonetic!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontFamily: 'Courier',
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '释义',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _word!.definition!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamplesCard(BuildContext context) {
    if (_word!.examples == null || _word!.examples!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.format_list_numbered,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '例句',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_word!.examples!.take(3).map((example) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        example,
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 16,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControl(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // Play button
          GestureDetector(
            onTap: _isPlaying ? null : _playPronunciation,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isPlaying ? Colors.white54 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '播放',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _isPlaying
                          ? Colors.grey
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Audio player (simple)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.graphic_eq,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '音效',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Volume slider
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '音量',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade700,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.volume_down,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '50%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade700,
                          ),
                    ),
                  ],
                ),
                Slider(
                  value: 0.5,
                  max: 1.0,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    // TODO: Implement actual volume control
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleSentenceCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '示例',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                'This is an example with ${_word!.word} in it.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEtymologyCard(BuildContext context) {
    // 尝试从词根词缀数据库获取信息
    final etymologyInfo = _getEtymologyInfo();

    // 如果没有词根词缀信息，不显示卡片
    if (etymologyInfo == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_tree,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  '词根词缀',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 词根说明
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.spellcheck,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '词根',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${etymologyInfo.root} - ${etymologyInfo.rootMeaning}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 衍生词示例
            if (etymologyInfo.examples.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                '衍生词',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...etymologyInfo.examples.take(4).map((example) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          example.word,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (example.breakdown != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            example.breakdown!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          example.meaning,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  EtymologyInfo? _getEtymologyInfo() {
    // 首先���查单词的etymology字段
    if (_word?.etymology != null && _word!.etymology!.isNotEmpty) {
      // 如果有自定义的词源信息，可以直接使用
      // 这里简单处理，实际可能需要解析格式化的数据
      return null; // 暂时返回null，使用数据库
    }

    // 从词根词缀数据库查找
    final wordLower = _word!.word.toLowerCase();

    // ��试匹配已知词根
    for (final entry in EtymologyService.database.entries) {
      final root = entry.key;
      final info = entry.value;

      // 检查单词是否包含该词根
      if (wordLower.contains(root)) {
        // 找到匹配的词根，返回信息
        return info;
      }
    }

    return null;
  }

  void _showSynonymsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('同义词'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: (_word!.synonyms ?? []).map((synonym) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Card(
                  child: ListTile(
                    title: Text(synonym),
                    trailing: IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _playPronunciation(synonym);
                      },
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return '初级';
      case 2:
        return '中级';
      case 3:
        return '高级';
      case 4:
        return '专业';
      default:
        return '未知';
    }
  }
}
