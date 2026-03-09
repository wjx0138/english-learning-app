import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/card_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../data/models/word.dart';
import '../../../core/utils/srs_algorithm.dart';
import 'widgets/animated_flashcard.dart';
import 'widgets/rating_buttons.dart';
import 'study_result_page.dart';

/// Enhanced Flashcard Learning Page with Animations
class EnhancedFlashcardPage extends StatefulWidget {
  const EnhancedFlashcardPage({super.key});

  @override
  State<EnhancedFlashcardPage> createState() => _EnhancedFlashcardPageState();
}

class _EnhancedFlashcardPageState extends State<EnhancedFlashcardPage> {
  bool _showAnswer = false;
  bool _hasAnswered = false;
  DateTime? _sessionStartTime;

  List<Word> _vocabulary = [];
  bool _isLoading = true;
  int _currentWordIndex = 0;
  bool _hasRecordedProgress = false;
  final List<String> _correctWordIds = [];
  int? _lastSeenDailyGoal; // Track daily goal changes

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    // Use Future.microtask to avoid setState during build
    Future.microtask(() => _loadVocabulary());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if daily goal has changed
    final progressProvider = context.read<ProgressProvider>();
    if (_lastSeenDailyGoal == null) {
      _lastSeenDailyGoal = progressProvider.dailyGoal;
    } else if (_lastSeenDailyGoal != progressProvider.dailyGoal) {
      final oldGoal = _lastSeenDailyGoal!;
      _lastSeenDailyGoal = progressProvider.dailyGoal;
      // Reload vocabulary when daily goal changes (only if not in active session)
      if (_currentWordIndex == 0 || _currentWordIndex >= _vocabulary.length) {
        _reloadWithNewGoal(progressProvider.dailyGoal);
      }
    }
  }

  Future<void> _reloadWithNewGoal(int newGoal) async {
    try {
      final appProvider = context.read<AppProvider>();
      if (appProvider.words.isNotEmpty && mounted) {
        // Only reload if not in the middle of an active session
        if (_currentWordIndex == 0 || _currentWordIndex >= _vocabulary.length) {
          setState(() {
            _vocabulary = appProvider.words.take(newGoal).toList();
            _currentWordIndex = 0;
            _showAnswer = false;
            _hasAnswered = false;
            _hasRecordedProgress = false;
            _correctWordIds.clear();
          });
          _loadNextCard();
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error reloading vocabulary: $e');
    }
  }

  Future<void> _loadVocabulary() async {
    try {
      final appProvider = context.read<AppProvider>();
      final progressProvider = context.read<ProgressProvider>();

      // Initialize last seen daily goal
      _lastSeenDailyGoal = progressProvider.dailyGoal;

      // Check if there's an incomplete session
      if (progressProvider.incompleteSession != null) {
        final session = progressProvider.incompleteSession!;
        final List<String> wordIds = List<String>.from(session['word_ids']);
        final int currentIndex = session['current_index'];

        // Find the words from the available vocabulary
        final allWords = appProvider.words;
        final sessionWords = allWords.where((word) => wordIds.contains(word.id)).toList();

        // Sort words according to the original order
        sessionWords.sort((a, b) => wordIds.indexOf(a.id).compareTo(wordIds.indexOf(b.id)));

        if (sessionWords.isNotEmpty) {
          setState(() {
            _vocabulary = sessionWords;
            _currentWordIndex = currentIndex;
            _isLoading = false;
          });
          _loadNextCard();
          return;
        }
      }

      // No incomplete session, start fresh
      if (appProvider.words.isNotEmpty) {
        setState(() {
          _vocabulary = appProvider.words.take(progressProvider.dailyGoal).toList();
          _isLoading = false;
        });
        _loadNextCard();
        return;
      }

      // Fallback to loading from assets
      final jsonString =
          await rootBundle.loadString('assets/vocabularies/cet4_sample.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _vocabulary = jsonList.map((json) => Word.fromJson(json)).toList();
        _isLoading = false;
      });
      _loadNextCard();
    } catch (e) {
      // If all fails, print error and show empty state
      // ignore: avoid_print
      print('Error loading vocabulary: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadNextCard() {
    if (_currentWordIndex < _vocabulary.length) {
      final word = _vocabulary[_currentWordIndex];
      final card = FSRSCard(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        wordId: word.id,
        createdAt: DateTime.now(),
        nextReview: DateTime.now(),
      );

      context.read<CardProvider>().loadCard(word, card);
    }
  }

  void _showAnswerCard() {
    setState(() {
      _showAnswer = true;
    });
  }

  void _submitAnswer(int rating) {
    if (_hasAnswered) return;

    final cardProvider = context.read<CardProvider>();
    cardProvider.submitAnswer(rating);

    // 记录正确的单词
    if (rating != FSRSAlgorithm.ratingAgain &&
        _currentWordIndex < _vocabulary.length) {
      _correctWordIds.add(_vocabulary[_currentWordIndex].id);
    }

    // 立即进入下一个单词
    setState(() {
      _hasAnswered = false;
      _showAnswer = false;
      _currentWordIndex++;
    });

    // 检查是否完成所有单词
    if (_currentWordIndex >= _vocabulary.length) {
      _handleSessionComplete(cardProvider);
    } else {
      _loadNextCard();
    }
  }

  void _handleSessionComplete(CardProvider cardProvider) async {
    if (!_hasRecordedProgress) {
      _hasRecordedProgress = true;

      // Calculate study time in minutes
      final studyDuration = _sessionStartTime != null
          ? DateTime.now().difference(_sessionStartTime!)
          : Duration.zero;
      final studyMinutes = (studyDuration.inSeconds / 60).ceil();

      final progressProvider = context.read<ProgressProvider>();
      await progressProvider.recordStudySession(
        cardsStudied: cardProvider.cardsStudied,
        correctAnswers: cardProvider.correctAnswers,
        wrongAnswers: cardProvider.wrongAnswers,
        correctWordIds: _correctWordIds,
        studyMinutes: studyMinutes > 0 ? studyMinutes : null,
        studyMode: 'flashcard',
      );

      // Clear incomplete session when completed
      await progressProvider.clearIncompleteSession();
    }

    // Navigate to result page
    final studyDuration = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!)
        : Duration.zero;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => StudyResultPage(
          totalCards: _vocabulary.length,
          correctCards: cardProvider.correctAnswers,
          wrongCards: cardProvider.wrongAnswers,
          studyDuration: studyDuration,
          wrongWordIds: cardProvider.wrongWordIds,
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出学习？'),
        content: Text(
          '当前进度: $_currentWordIndex/${_vocabulary.length} 张卡片\n已学习的进度将被保存，下次可继续学习',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('继续学习'),
          ),
          TextButton(
            onPressed: () async {
              // Save progress before exiting
              final progressProvider = context.read<ProgressProvider>();
              final wordIds = _vocabulary.map((w) => w.id).toList();

              await progressProvider.saveIncompleteSession(
                wordIds: wordIds,
                currentIndex: _currentWordIndex,
                totalCards: _vocabulary.length,
                vocabularyId: 'current',
              );

              if (mounted) {
                Navigator.of(context).pop();
                context.go('/');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('保存并退出'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = context.watch<CardProvider>();
    final currentWord = cardProvider.currentWord;

    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_vocabulary.isEmpty) {
      return _buildEmptyState();
    }

    if (currentWord == null) {
      return _buildLoadingState();
    }

    return Scaffold(
      appBar: AppBar(
        title: Consumer<ProgressProvider>(
          builder: (context, progressProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('卡片学习', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 0), // 隐藏"今日已学习"文字但保留Consumer监听
              ],
            );
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _showExitDialog,
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text(
                  '${_currentWordIndex + 1}/${_vocabulary.length}',
                ),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentWordIndex + 1) / _vocabulary.length,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            minHeight: 8,
          ),

          // Card area
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Flashcard
                    AnimatedFlashcard(
                      word: currentWord,
                      showAnswer: _showAnswer,
                      onFlip: _showAnswerCard,
                    ),
                    const SizedBox(height: 48),

                    // Show Answer button (when answer is hidden)
                    if (!_showAnswer)
                      ElevatedButton.icon(
                        onPressed: _showAnswerCard,
                        icon: const Icon(Icons.visibility),
                        label: const Text('显示答案'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 20,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    // Rating buttons (when answer is shown)
                    if (_showAnswer)
                      CardRatingButtons(
                        showAnswer: _showAnswer,
                        onRate: _hasAnswered ? (_) {} : _submitAnswer,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('卡片学习'),
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

  Widget _buildEmptyState() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('卡片学习'),
      ),
      body: Center(
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
                // Navigate to course center page
                context.push('/courses');
              },
              icon: const Icon(Icons.add),
              label: const Text('选择词库'),
            ),
          ],
        ),
      ),
    );
  }
}
