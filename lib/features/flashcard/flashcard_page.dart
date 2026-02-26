import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/card_provider.dart';
import '../../../core/providers/progress_provider.dart';
import '../../../data/models/word.dart';
import '../../../core/utils/srs_algorithm.dart';
import 'widgets/card_widget.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  bool _showAnswer = false;
  bool _hasAnswered = false;

  List<Word> _vocabulary = [];
  bool _isLoading = true;
  int _currentWordIndex = 0;
  bool _hasRecordedProgress = false;
  final List<String> _correctWordIds = []; // Track words answered correctly

  @override
  void initState() {
    super.initState();
    _loadVocabulary();
  }

  Future<void> _loadVocabulary() async {
    try {
      final jsonString = await rootBundle.loadString('assets/vocabularies/cet4_sample.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      setState(() {
        _vocabulary = jsonList.map((json) => Word.fromJson(json)).toList();
        _isLoading = false;
      });
      _loadNextCard();
    } catch (e) {
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
    // Prevent multiple submissions
    if (_hasAnswered) return;

    setState(() {
      _hasAnswered = true;
    });

    final cardProvider = context.read<CardProvider>();
    cardProvider.submitAnswer(rating);

    // Track correctly answered words
    if (rating != FSRSAlgorithm.ratingAgain && _currentWordIndex < _vocabulary.length) {
      _correctWordIds.add(_vocabulary[_currentWordIndex].id);
    }

    // Move to next card after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        // Increment index first
        setState(() {
          _currentWordIndex++;
        });

        // Check if all cards are completed
        if (_currentWordIndex >= _vocabulary.length) {
          // Record progress when all cards are studied
          if (!_hasRecordedProgress) {
            _hasRecordedProgress = true;
            final cardProvider = context.read<CardProvider>();
            final progressProvider = context.read<ProgressProvider>();
            progressProvider.recordStudySession(
              cardsStudied: cardProvider.cardsStudied,
              correctAnswers: cardProvider.correctAnswers,
              wrongAnswers: cardProvider.wrongAnswers,
              correctWordIds: _correctWordIds,
            );
          }
        } else {
          // Load next card
          _loadNextCard();
          // Reset UI state for next card
          setState(() {
            _showAnswer = false;
            _hasAnswered = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardProvider = context.watch<CardProvider>();
    final currentWord = cardProvider.currentWord;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('卡片学习'),
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

    if (currentWord == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('卡片学习'),
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
              Text('加载中...'),
            ],
          ),
        ),
      );
    }

    if (_currentWordIndex >= _vocabulary.length) {
      return _buildCompletionPage(context, cardProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('卡片学习'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Chip(
                label: Text(
                  '进度: ${_currentWordIndex + 1}/${_vocabulary.length}',
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
              value: (_currentWordIndex + 1) / _vocabulary.length,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),

            // Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FlashcardWidget(
                  word: currentWord,
                  showAnswer: _showAnswer,
                  onFlip: _showAnswerCard,
                ),
              ),
            ),

            // Action buttons
            if (_showAnswer)
              _buildAnswerButtons(context)
            else
              _buildShowAnswerButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildShowAnswerButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: ElevatedButton(
        onPressed: _showAnswerCard,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        child: const Text(
          '显示答案',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildAnswerButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAnswerButton(
            context,
            label: '忘记了',
            icon: Icons.close,
            color: Colors.red,
            rating: FSRSAlgorithm.ratingAgain,
          ),
          _buildAnswerButton(
            context,
            label: '困难',
            icon: Icons.sentiment_dissatisfied,
            color: Colors.orange,
            rating: FSRSAlgorithm.ratingHard,
          ),
          _buildAnswerButton(
            context,
            label: '一般',
            icon: Icons.sentiment_neutral,
            color: Colors.blue,
            rating: FSRSAlgorithm.ratingGood,
          ),
          _buildAnswerButton(
            context,
            label: '简单',
            icon: Icons.sentiment_very_satisfied,
            color: Colors.green,
            rating: FSRSAlgorithm.ratingEasy,
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required int rating,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _submitAnswer(rating),
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: color, width: 2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionPage(BuildContext context, CardProvider cardProvider) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('学习完成'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 80,
                color: Colors.amber,
              ),
              const SizedBox(height: 24),
              Text(
                '学习完成！',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 32),
              _buildStatCard(
                context,
                '学习卡片',
                '${cardProvider.cardsStudied}',
                Icons.style,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                context,
                '正确率',
                '${(cardProvider.accuracy * 100).toStringAsFixed(0)}%',
                Icons.check_circle,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                context,
                '错误单词',
                '${cardProvider.wrongAnswers}',
                Icons.error_outline,
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      cardProvider.resetSession();
                      setState(() {
                        _currentWordIndex = 0;
                        _hasRecordedProgress = false;
                      });
                      _loadNextCard();
                    },
                    icon: const Icon(Icons.replay),
                    label: const Text('重新��始'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.push('/progress');
                    },
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('查看统计'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.pop();
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('返回首页'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
