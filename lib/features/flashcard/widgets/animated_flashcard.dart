import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Animated Flashcard with Flip Animation
class AnimatedFlashcard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool showAnswer;
  final VoidCallback? onTap;
  final Duration animationDuration;

  const AnimatedFlashcard({
    super.key,
    required this.front,
    required this.back,
    this.showAnswer = false,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  @override
  State<AnimatedFlashcard> createState() => _AnimatedFlashcardState();
}

class _AnimatedFlashcardState extends State<AnimatedFlashcard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Initial state
    _isFront = !widget.showAnswer;
  }

  @override
  void didUpdateWidget(AnimatedFlashcard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showAnswer != widget.showAnswer) {
      if (widget.showAnswer && _isFront) {
        // Flip to back
        _controller.forward().then((_) {
          setState(() {
            _isFront = false;
          });
          _controller.forward(from: 0);
        });
      } else if (!widget.showAnswer && !_isFront) {
        // Flip to front
        _controller.forward().then((_) {
          setState(() {
            _isFront = true;
          });
          _controller.forward(from: 0);
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final isUnder = _animation.value < 0.5;
          final angle = _animation.value * math.pi;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_isFront ? angle : -angle),
            child: isUnder
                ? _isFront
                    ? widget.front
                    : widget.back
                : _isFront
                    ? widget.back
                    : widget.front,
          );
        },
      ),
    );
  }
}

/// Flashcard content for word learning
class WordFlashcardContent extends StatelessWidget {
  final String word;
  final String? phonetic;
  final String definition;
  final List<String> examples;
  final bool isFront;
  final bool showPhonetic;

  const WordFlashcardContent({
    super.key,
    required this.word,
    this.phonetic,
    required this.definition,
    this.examples = const [],
    this.isFront = true,
    this.showPhonetic = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFront
              ? [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primaryContainer,
                ]
              : [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.secondaryContainer,
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isFront) ...[
              _buildFrontContent(context),
            ] else ...[
              _buildBackContent(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFrontContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          word,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
          textAlign: TextAlign.center,
        ),
        if (phonetic != null && showPhonetic) ...[
          const SizedBox(height: 16),
          Text(
            phonetic!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontFamily: 'Courier',
                ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 48),
        Icon(
          Icons.touch_app,
          size: 48,
          color: Colors.white54,
        ),
        const SizedBox(height: 16),
        Text(
          '点击查看答案',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
        ),
      ],
    );
  }

  Widget _buildBackContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            word,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              definition,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          if (examples.isNotEmpty) ...[
            const SizedBox(height: 24),
            ...examples.take(2).map((example) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '• ',
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                    Expanded(
                      child: Text(
                        example,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
