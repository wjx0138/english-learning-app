import 'package:flutter/material.dart';
import '../../../data/models/word.dart';
import '../../../shared/services/tts_service.dart';

/// Flashcard widget with flip animation
class FlashcardWidget extends StatefulWidget {
  final Word word;
  final bool showAnswer;
  final VoidCallback? onFlip;

  const FlashcardWidget({
    super.key,
    required this.word,
    required this.showAnswer,
    this.onFlip,
  });

  @override
  State<FlashcardWidget> createState() => _FlashcardWidgetState();
}

class _FlashcardWidgetState extends State<FlashcardWidget>
    with SingleTickerProviderStateMixin {
  final TTSService _ttsService = TTSService();
  bool _isPlaying = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    // Initialize flip state if widget starts with showAnswer = true
    if (widget.showAnswer) {
      _isFlipped = true;
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlashcardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnswer != oldWidget.showAnswer) {
      _flipCard();
    }
  }

  void _flipCard() {
    if (_isFlipped != widget.showAnswer) {
      _isFlipped = widget.showAnswer;
      if (widget.showAnswer) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  Future<void> _playPronunciation() async {
    setState(() {
      _isPlaying = true;
    });
    await _ttsService.speakWord(widget.word.word);
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onFlip?.call();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isShowingBack = _animation.value > 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(_animation.value * 3.14159),
            child: isShowingBack
                ? _buildBack(context)
                : _buildFront(context),
          );
        },
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.help_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.word.word,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (widget.word.phonetic != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.word.phonetic!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Text(
                    '点击查看释义',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ],
              ),
            ),
          ),
          // Speaker button
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              onPressed: _playPronunciation,
              icon: Icon(
                _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(3.14159),
      child: Container(
        width: double.infinity,
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.word.word,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.word.definition,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                if (widget.word.examples.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    '例句',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.word.examples.first,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                if (widget.word.difficulty > 0) ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: List.generate(
                      widget.word.difficulty,
                      (index) => Icon(
                        Icons.star,
                        size: 16,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
