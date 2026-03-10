import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/word.dart';
import '../../data/models/typing_practice.dart';
import '../../data/models/gamification.dart';
import '../../data/models/quiz.dart';
import '../../core/providers/app_provider.dart';
import '../../core/providers/progress_provider.dart';
import '../../shared/services/tts_service.dart';
import '../../shared/services/audio_service.dart';
import '../../shared/services/error_book_service.dart';
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
  late TypingSession _session;
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
    // Record study time when leaving the page
    _recordStudySessionOnExit();
    _ttsService.stop();
    // Note: AudioService is a singleton, don't dispose it here
    super.dispose();
  }

  /// Record study session when user exits the page (enters page -> leaves page)
  Future<void> _recordStudySessionOnExit() async {
    // Don't record if already completed or no words practiced
    if (_session.endTime != null) return;
    if (_session.results.isEmpty) return;

    try {
      // Set end time
      _session = _session.copyWith(endTime: DateTime.now());

      // Calculate study time in minutes
      final duration = _session.endTime!.difference(_session.startTime);
      final practiceMinutes = (duration.inSeconds / 60).ceil();

      if (practiceMinutes <= 0) return;

      // Get correct word IDs
      final correctWordIds = _session.results
          .where((r) => r.isCorrect)
          .map((r) => r.wordId)
          .toList();

      final progressProvider = context.read<ProgressProvider>();
      await progressProvider.recordStudySession(
        cardsStudied: _session.totalWords,
        correctAnswers: _session.correctWords,
        wrongAnswers: _session.wrongWords,
        correctWordIds: correctWordIds,
        studyMinutes: practiceMinutes,
        studyMode: widget.initialMode == TypingMode.dictation ? 'dictation' : 'typing',
      );
    } catch (e) {
      // Provider might not be available during dispose
      // ignore: avoid_print
      print('Error recording study session: $e');
    }
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

          // Stop any pending audio playback before moving to next word
          _ttsService.stop();

          // Only auto-play audio in dictation mode when answer is correct
          // Don't auto-play after wrong answers
          if (isCorrect && widget.initialMode == TypingMode.dictation) {
            _playWordAudio();
          }
        }
      } else {
        // Try again
        _currentAttempt++;
        _wordStartTime = DateTime.now();
      }
    });

    // Save wrong answers to error book
    if (!isCorrect) {
      _saveToErrorBook(word);
    }
  }

  /// Save word to error book for dictation/typing practice
  Future<void> _saveToErrorBook(Word word) async {
    try {
      // Create a QuizQuestion from Word for error book compatibility
      final question = QuizQuestion(
        id: 'dictation_${word.id}',
        wordId: word.id,
        word: word.word,
        question: widget.initialMode == TypingMode.dictation
            ? '听写练习：请拼写这个单词'
            : '跟打练习：请拼写这个单词',
        type: QuizQuestionType.spelling,
        options: [
          QuizOption(id: '1', text: word.word, isCorrect: true),
          QuizOption(id: '2', text: '', isCorrect: false),
        ],
        correctOptionIndex: 0,
        explanation: word.definition,
        createdAt: DateTime.now(),
      );

      // Create a wrong answer (option index 1 means wrong)
      final answer = QuizAnswer(
        questionIndex: _currentIndex,
        selectedOptionIndex: 1, // Mark as wrong
        isCorrect: false,
        timestamp: DateTime.now(),
        timeTaken: const Duration(seconds: 0),
      );

      await ErrorBookService.addError(answer, question);
    } catch (e) {
      // Silently fail if error book save fails
      if (mounted) {
        debugPrint('Failed to save to error book: $e');
      }
    }
  }

  Future<void> _addCompletionRewards() async {
    // Record study session when completing
    await _recordStudySessionOnExit();

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

        // Stop any pending audio playback before playing next word
        _ttsService.stop();

        // Auto-play audio for next word in dictation mode after skipping
        if (widget.initialMode == TypingMode.dictation) {
          _playWordAudio();
        }
      }
    });

    // Save skipped words to error book
    _saveToErrorBook(word);
  }

  void _handleReplay() {
    _playWordAudio();
  }

  void _goBack() {
    Navigator.of(context).pop(_session);
  }

  @override
  Widget build(BuildContext context) {
    // 如果已完成，显示结果页面
    if (_isCompleted) {
      return _buildResultsPage();
    }

    // 检查是否还有单词需要练习
    if (_currentIndex >= _practiceWords.length) {
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

              // Typing input - 只在未完成且有单词时显示
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
        ElevatedButton.icon(
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
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
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
