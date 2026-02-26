import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/word.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../shared/services/tts_service.dart';

class TypingPage extends StatefulWidget {
  const TypingPage({super.key});

  @override
  State<TypingPage> createState() => _TypingPageState();
}

class _TypingPageState extends State<TypingPage> {
  final TTSService _ttsService = TTSService();
  List<Word> _vocabulary = [];
  bool _isLoading = true;
  int _currentWordIndex = 0;

  // Typing state
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _userInput = '';
  bool _isCorrect = false;
  bool _hasAttempted = false;

  // Statistics
  int _totalWords = 0;
  int _correctWords = 0;
  int _wrongWords = 0;
  final List<String> _wrongWordIds = [];
  final List<String> _correctWordIds = []; // Track words typed correctly
  double _accuracy = 0.0;
  bool _hasRecordedProgress = false;

  // Speed tracking
  DateTime? _wordStartTime;
  final List<int> _wordTimings = [];
  int _totalCharactersTyped = 0;

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
    _textController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadVocabulary() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/vocabularies/cet4_sample.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _vocabulary = jsonList.map((json) => Word.fromJson(json)).toList();
        _isLoading = false;
        _totalWords = _vocabulary.length;
      });
      _focusNode.requestFocus();
      _startWordTimer();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startWordTimer() {
    _wordStartTime = DateTime.now();
  }

  void _onInputChanged() {
    final input = _textController.text.toLowerCase().trim();
    setState(() {
      _userInput = input;
      _hasAttempted = input.isNotEmpty;
      _totalCharactersTyped = input.length;

      if (input.isNotEmpty) {
        final currentWord = _vocabulary[_currentWordIndex].word.toLowerCase();
        _isCorrect = input == currentWord;

        // Auto-submit when correct
        if (_isCorrect) {
          _submitWord(true);
        }
      }
    });
  }

  void _submitWord(bool isAutoSubmit) {
    if (_wordStartTime != null) {
      final duration = DateTime.now().difference(_wordStartTime!).inMilliseconds;
      _wordTimings.add(duration);
    }

    final currentWord = _vocabulary[_currentWordIndex];
    final wasCorrect = _isCorrect;

    setState(() {
      if (wasCorrect) {
        _correctWords++;
        _correctWordIds.add(currentWord.id);
      } else {
        _wrongWords++;
        _wrongWordIds.add(currentWord.id);
      }

      _accuracy = _correctWords + _wrongWords > 0
          ? (_correctWords / (_correctWords + _wrongWords)) * 100
          : 0.0;
    });

    // Move to next word after a brief delay
    Future.delayed(Duration(milliseconds: wasCorrect ? 300 : 1000), () {
      if (mounted) {
        _nextWord();
      }
    });
  }

  void _nextWord() {
    setState(() {
      _currentWordIndex++;
      _textController.clear();
      _userInput = '';
      _isCorrect = false;
      _hasAttempted = false;
      _wordStartTime = DateTime.now();
    });

    if (_currentWordIndex >= _vocabulary.length) {
      // Record progress when all words are completed
      if (!_hasRecordedProgress) {
        _hasRecordedProgress = true;
        context.read<ProgressProvider>().recordStudySession(
          cardsStudied: _totalWords,
          correctAnswers: _correctWords,
          wrongAnswers: _wrongWords,
          correctWordIds: _correctWordIds,
        );
      }
      _showCompletionDialog();
    }
  }

  void _skipWord() {
    final currentWord = _vocabulary[_currentWordIndex];
    setState(() {
      _wrongWords++;
      _wrongWordIds.add(currentWord.id);
      _accuracy = _correctWords + _wrongWords > 0
          ? (_correctWords / (_correctWords + _wrongWords)) * 100
          : 0.0;
    });
    _nextWord();
  }

  void _resetSession() {
    setState(() {
      _currentWordIndex = 0;
      _correctWords = 0;
      _wrongWords = 0;
      _wrongWordIds.clear();
      _correctWordIds.clear();
      _accuracy = 0.0;
      _wordTimings.clear();
      _totalCharactersTyped = 0;
      _textController.clear();
      _userInput = '';
      _isCorrect = false;
      _hasAttempted = false;
      _wordStartTime = DateTime.now();
      _hasRecordedProgress = false;
    });
    _focusNode.requestFocus();
  }

  void _showCompletionDialog() {
    final avgTimePerWord = _wordTimings.isNotEmpty
        ? _wordTimings.reduce((a, b) => a + b) / _wordTimings.length / 1000
        : 0.0;
    final wpm = avgTimePerWord > 0 ? (60 / avgTimePerWord).round() : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('练习完成！'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatItem('总词数', '$_totalWords', Icons.format_list_numbered),
            const SizedBox(height: 12),
            _buildStatItem('正确', '$_correctWords', Icons.check_circle, Colors.green),
            const SizedBox(height: 12),
            _buildStatItem('错误', '$_wrongWords', Icons.cancel, Colors.red),
            const SizedBox(height: 12),
            _buildStatItem('正确率', '${_accuracy.toStringAsFixed(1)}%', Icons.pie_chart),
            const SizedBox(height: 12),
            _buildStatItem('平均速度', '$wpm WPM', Icons.speed, Colors.blue),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetSession();
            },
            child: const Text('重新练习'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/progress');
            },
            child: const Text('查看统计'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('返回首页'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, [Color? color]) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color ?? Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('打字练习'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('加载词库中...'),
            ],
          ),
        ),
      );
    }

    if (_vocabulary.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('打字练习'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: const Center(
          child: Text('词库加载失败，请重试'),
        ),
      );
    }

    if (_currentWordIndex >= _vocabulary.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('打字练习'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.pop();
            },
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentWord = _vocabulary[_currentWordIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('打字练习'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text(
                  '进度: ${_currentWordIndex + 1}/$_totalWords',
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            LinearProgressIndicator(
              value: (_currentWordIndex + 1) / _totalWords,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),

            // Statistics bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip('正确', _correctWords.toString(), Colors.green),
                  _buildStatChip('错误', _wrongWords.toString(), Colors.red),
                  _buildStatChip('正确率', '${_accuracy.toStringAsFixed(0)}%', Colors.blue),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Word display
                    _buildWordDisplay(currentWord),

                    const SizedBox(height: 32),

                    // Input field
                    _buildInputField(),

                    const SizedBox(height: 16),

                    // Feedback
                    if (_hasAttempted)
                      _buildFeedback(),

                    const SizedBox(height: 24),

                    // Skip button
                    if (!_isCorrect && _hasAttempted)
                      OutlinedButton.icon(
                        onPressed: _skipWord,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('跳过'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildWordDisplay(Word word) {
    return Column(
      children: [
        // Speaker button
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () => _ttsService.speakWord(word.word),
              icon: const Icon(
                Icons.volume_up,
                color: Colors.grey,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.1),
                padding: const EdgeInsets.all(12),
              ),
              tooltip: '播放发音',
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Phonetic
        if (word.phonetic != null)
          Text(
            word.phonetic!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
          ),
        const SizedBox(height: 8),

        // Word to type
        Text(
          word.word,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),

        // Definition (hidden initially, shown as hint)
        Text(
          word.definition,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputField() {
    return TextField(
      controller: _textController,
      focusNode: _focusNode,
      autofocus: true,
      textCapitalization: TextCapitalization.none,
      decoration: InputDecoration(
        hintText: '输入上面的单词...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: _hasAttempted
            ? (_isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1))
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _hasAttempted
                ? (_isCorrect ? Colors.green : Colors.red)
                : Colors.grey,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: _hasAttempted
                ? (_isCorrect ? Colors.green : Colors.red)
                : Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        suffixIcon: _hasAttempted
            ? Icon(
                _isCorrect ? Icons.check_circle : Icons.cancel,
                color: _isCorrect ? Colors.green : Colors.red,
                size: 28,
              )
            : null,
      ),
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
      onSubmitted: (_) {
        if (_isCorrect) {
          _submitWord(true);
        } else if (_hasAttempted) {
          _submitWord(false);
        }
      },
    );
  }

  Widget _buildFeedback() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: _isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isCorrect ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isCorrect ? Icons.check_circle : Icons.error,
            color: _isCorrect ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            _isCorrect ? '正确！' : '再试一次',
            style: TextStyle(
              color: _isCorrect ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
