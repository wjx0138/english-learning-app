import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/word.dart';
import '../../data/models/typing_practice.dart';
import '../../data/models/gamification.dart';
import '../../core/providers/app_provider.dart';
import '../../shared/services/tts_service.dart';
import '../../shared/services/gamification_service.dart';
import '../../shared/services/audio_service.dart';
import 'widgets/typing_input_widget.dart';
import 'widgets/typing_stats_widget.dart';

/// Typing Practice Page
class TypingPracticePage extends StatefulWidget {
  final List<Word> words;
  final TypingMode initialMode;

  const TypingPracticePage({
    super.key,
    required this.words,
    this.initialMode = TypingMode.visible,
  });

  @override
  State<TypingPracticePage> createState() => _TypingPracticePageState();
}

class _TypingPracticePageState extends State<TypingPracticePage> {
  late final TypingSession _session;
  late final List<Word> _practiceWords;
  late final TTSService _ttsService;
  late final AudioService _audioService;

  int _currentIndex = 0;
  bool _isCompleted = false;
  DateTime? _wordStartTime;
  int _currentAttempt = 1;
  final int _maxAttempts = 3;

  @override
  void initState() {
    super.initState();
    _practiceWords = List.from(widget.words);
    _ttsService = TTSService();
    _audioService = AudioService();

    // Initialize session
    _session = TypingSession(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
      mode: widget.initialMode,
      results: [],
      wordIds: _practiceWords.map((w) => w.id).toList(),
    );

    _wordStartTime = DateTime.now();

    // Auto-play audio if in dictation mode
    if (widget.initialMode == TypingMode.dictation) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _playWordAudio();
      });
    }
  }

  @override
  void dispose() {
    _ttsService.stop();
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _playWordAudio() async {
    if (_currentIndex >= _practiceWords.length) return;

    final word = _practiceWords[_currentIndex];
    await _ttsService.speak(word.word);
  }

  void _handleSubmit(bool isCorrect) {
    final word = _practiceWords[_currentIndex];
    final timeTaken = DateTime.now().difference(_wordStartTime!);

    // Play sound effect
    if (isCorrect) {
      _audioService.playCorrectSound();
    } else {
      _audioService.playWrongSound();
    }

    // Add points for correct typing
    if (isCorrect) {
      final appProvider = context.read<AppProvider>();
      // Base 3 points + bonus for first attempt
      final points = 3 + (_currentAttempt == 1 ? 2 : 0);
      appProvider.addPoints(points, type: PointEventType.correctAnswer);
    }

    // Record result
    final result = TypingResult(
      wordId: word.id,
      targetWord: word.word,
      userInput: isCorrect ? word.word : '',
      isCorrect: isCorrect,
      timeTaken: timeTaken,
      timestamp: DateTime.now(),
      attempts: _currentAttempt,
    );

    setState(() {
      _session.results.add(result);

      if (isCorrect || _currentAttempt >= _maxAttempts) {
        // Move to next word
        _currentAttempt = 1;
        _currentIndex++;

        if (_currentIndex >= _practiceWords.length) {
          // Session completed
          _isCompleted = true;
          _session = _session.copyWith(
            endTime: DateTime.now(),
          );

          // Add gamification rewards (fire and forget)
          unawaited(_addCompletionRewards());
        } else {
          _wordStartTime = DateTime.now();

          // Play audio for next word if in dictation mode
          if (widget.initialMode == TypingMode.dictation) {
            _playWordAudio();
          }
        }
      } else {
        // Try again
        _currentAttempt++;
        _wordStartTime = DateTime.now();
      }
    });

    // Save wrong words to error book
    if (!isCorrect) {
      _saveToErrorBook(word);
    }
  }

  Future<void> _addCompletionRewards() async {
    final appProvider = context.read<AppProvider>();
    final duration = _session.endTime!.difference(_session.startTime);
    final practiceMinutes = (duration.inSeconds / 60).ceil();

    // Play completion sound
    _audioService.playCompleteSound();

    // Record study activity
    appProvider.recordStudy(
      wordsLearned: _session.correctWords,
      practiceMinutes: practiceMinutes,
    );

    // Check for achievements
    final newlyUnlocked = await appProvider.checkAchievements();
    if (newlyUnlocked.isNotEmpty) {
      // Play achievement sound
      _audioService.playAchievementSound();
    }
  }

  void _handleSkip() {
    final word = _practiceWords[_currentIndex];
    final timeTaken = DateTime.now().difference(_wordStartTime!);

    // Record as incorrect
    final result = TypingResult(
      wordId: word.id,
      targetWord: word.word,
      userInput: '',
      isCorrect: false,
      timeTaken: timeTaken,
      timestamp: DateTime.now(),
      attempts: _currentAttempt,
    );

    setState(() {
      _session.results.add(result);
      _currentAttempt = 1;
      _currentIndex++;

      if (_currentIndex >= _practiceWords.length) {
        _isCompleted = true;
        _session = _session.copyWith(
          endTime: DateTime.now(),
        );

        // Add gamification rewards (fire and forget)
        unawaited(_addCompletionRewards());
      } else {
        _wordStartTime = DateTime.now();

        // Play audio for next word if in dictation mode
        if (widget.initialMode == TypingMode.dictation) {
          _playWordAudio();
        }
      }
    });

    _saveToErrorBook(word);
  }

  void _saveToErrorBook(Word word) {
    // Get the AppProvider and save to error book
    // This will be implemented when we add error book functionality
    // For now, just print to console
    // print('Added to error book: ${word.word}');
  }

  void _handleReplay() {
    _playWordAudio();
  }

  void _goBack() {
    Navigator.of(context).pop(_session);
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return _buildResultsPage();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialMode == TypingMode.visible
            ? '跟打练习'
            : '听写练习'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showExitDialog();
          },
        ),
        actions: [
          // Mode toggle
          IconButton(
            icon: Icon(widget.initialMode == TypingMode.visible
                ? Icons.visibility
                : Icons.hearing),
            onPressed: () {
              _showModeDialog();
            },
            tooltip: '切换模式',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Statistics
              TypingStatsWidget(
                wordsCompleted: _currentIndex,
                wordsCorrect: _session.correctWords,
                wordsWrong: _session.wrongWords,
                wordsRemaining: _practiceWords.length - _currentIndex,
                accuracy: _session.accuracy,
                cpm: _session.averageCPM,
                totalDurationSeconds:
                    DateTime.now().difference(_session.startTime).inSeconds,
              ),
              const SizedBox(height: 48),

              // Typing input
              TypingInputWidget(
                targetWord: _practiceWords[_currentIndex].word,
                isDictationMode: widget.initialMode == TypingMode.dictation,
                showHint: true,
                onSubmit: _handleSubmit,
                onSkip: _handleSkip,
                onReplay: widget.initialMode == TypingMode.dictation
                    ? _handleReplay
                    : null,
                currentAttempt: _currentAttempt,
                maxAttempts: _maxAttempts,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('练习完成'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Congratulations message
            _buildCompletionCard(context),
            const SizedBox(height: 24),

            // Detailed stats
            _buildDetailedStats(context),
            const SizedBox(height: 24),

            // Wrong words (if any)
            if (_session.wrongWords > 0) _buildWrongWordsSection(context),
            const SizedBox(height: 24),

            // Action buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context) {
    final isExcellent = _session.accuracy >= 90;
    final isGood = _session.accuracy >= 70;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isExcellent
              ? [Colors.amber.shade400, Colors.amber.shade600]
              : isGood
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : [Colors.blue.shade400, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(
            isExcellent ? Icons.emoji_events : Icons.check_circle,
            size: 80,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            isExcellent
                ? '太棒了！'
                : isGood
                    ? '干得不错！'
                    : '继续努力！',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '正确率: ${_session.accuracy.toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats(BuildContext context) {
    final duration = _session.endTime!.difference(_session.startTime);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '详细统计',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(context, '完成单词', '${_session.totalWords} 个'),
            _buildStatRow(context, '正确', '${_session.correctWords} 个',
                color: Colors.green),
            _buildStatRow(context, '错误', '${_session.wrongWords} 个',
                color: Colors.red),
            _buildStatRow(context, '正确率', '${_session.accuracy.toStringAsFixed(1)}%'),
            _buildStatRow(context, '平均速度', '${_session.averageCPM.toStringAsFixed(0)} CPM'),
            _buildStatRow(context, '总耗时', _formatDuration(duration)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildWrongWordsSection(BuildContext context) {
    final wrongResults = _session.results.where((r) => !r.isCorrect).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  '错误单词',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Text(
                  '${wrongResults.length} 个',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...wrongResults.map((result) {
              return ListTile(
                title: Text(result.targetWord),
                subtitle: Text('尝试 ${result.attempts} 次'),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    _ttsService.speak(result.targetWord);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop(_session);
          },
          icon: const Icon(Icons.check),
          label: const Text('完成'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            // Restart with same words
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => TypingPracticePage(
                  words: widget.words,
                  initialMode: widget.initialMode,
                ),
              ),
            );
          },
          icon: const Icon(Icons.replay),
          label: const Text('再练一次'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ],
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出练习？'),
        content: const Text('您的进度将会保存。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('继续练习'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _goBack();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }

  void _showModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换模式'),
        content: const Text('切换模式将结束当前练习并开始新模式。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => TypingPracticePage(
                    words: widget.words,
                    initialMode: widget.initialMode == TypingMode.visible
                        ? TypingMode.dictation
                        : TypingMode.visible,
                  ),
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }
}
