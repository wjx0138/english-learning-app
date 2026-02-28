import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Typing Input Widget with Real-time Validation
class TypingInputWidget extends StatefulWidget {
  final String targetWord;
  final bool isDictationMode;
  final bool showHint;
  final Function(bool isCorrect) onSubmit;
  final VoidCallback? onSkip;
  final VoidCallback? onReplay;
  final int currentAttempt;
  final int maxAttempts;

  const TypingInputWidget({
    super.key,
    required this.targetWord,
    this.isDictationMode = false,
    this.showHint = true,
    required this.onSubmit,
    this.onSkip,
    this.onReplay,
    this.currentAttempt = 1,
    this.maxAttempts = 3,
  });

  @override
  State<TypingInputWidget> createState() => _TypingInputWidgetState();
}

class _TypingInputWidgetState extends State<TypingInputWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasError = false;
  String _currentInput = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    // Auto-focus when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _controller.addListener(() {
      setState(() {
        _currentInput = _controller.text;
        _hasError = false;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_currentInput.trim().isEmpty) return;

    final isCorrect = _currentInput.trim().toLowerCase() ==
        widget.targetWord.toLowerCase();

    if (isCorrect) {
      _controller.clear();
      setState(() {
        _currentInput = '';
      });
    } else {
      setState(() {
        _hasError = true;
      });
      // Vibrate on error
      HapticFeedback.vibrate();
    }

    widget.onSubmit(isCorrect);
  }

  void _handleSkip() {
    HapticFeedback.vibrate();
    _controller.clear();
    setState(() {
      _currentInput = '';
      _hasError = false;
    });
    widget.onSkip?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Target word display
        if (!widget.isDictationMode) ...[
          _buildTargetWord(),
          const SizedBox(height: 32),
        ],

        // Dictation mode indicator
        if (widget.isDictationMode) ...[
          Icon(
            Icons.hearing,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '听写模式',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          if (widget.onReplay != null)
            TextButton.icon(
              onPressed: widget.onReplay,
              icon: const Icon(Icons.replay),
              label: const Text('重新播放'),
            ),
          const SizedBox(height: 24),
        ],

        // Input field
        _buildInputField(),

        const SizedBox(height: 24),

        // Action buttons
        _buildActionButtons(),

        const SizedBox(height: 16),

        // Attempt counter
        _buildAttemptCounter(),

        // Progress indicator
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildTargetWord() {
    return Column(
      children: [
        Text(
          widget.targetWord,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        if (widget.showHint) ...[
          const SizedBox(height: 8),
          Text(
            '${widget.targetWord.length} 个字母',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField() {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        color: _hasError ? Colors.red[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasError ? Colors.red : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: _hasError ? Colors.red : null,
            ),
        decoration: InputDecoration(
          hintText: widget.isDictationMode ? '输入听到的单词' : '输入上面的单词',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          suffixIcon: _currentInput.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    _hasError ? Icons.close : Icons.check,
                    color: _hasError ? Colors.red : Colors.green,
                  ),
                  onPressed: () {
                    _controller.clear();
                    setState(() {
                      _currentInput = '';
                      _hasError = false;
                    });
                  },
                )
              : null,
        ),
        onSubmitted: (_) => _handleSubmit(),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
        ],
        textCapitalization: TextCapitalization.none,
        autofocus: true,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Submit button
        ElevatedButton.icon(
          onPressed: _currentInput.isNotEmpty ? _handleSubmit : null,
          icon: const Icon(Icons.check),
          label: const Text('提交'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(width: 16),
        // Skip button
        OutlinedButton.icon(
          onPressed: _handleSkip,
          icon: const Icon(Icons.skip_next),
          label: const Text('跳过'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildAttemptCounter() {
    return Text(
      '尝试 ${widget.currentAttempt}/${widget.maxAttempts}',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
    );
  }

  Widget _buildProgressIndicator() {
    if (!widget.showHint) return const SizedBox();

    final progress = _currentInput.length / widget.targetWord.length;
    final isOverLength = _currentInput.length > widget.targetWord.length;

    return Column(
      children: [
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: isOverLength ? 1.0 : progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            isOverLength ? Colors.orange : Colors.green,
          ),
        ),
      ],
    );
  }
}
