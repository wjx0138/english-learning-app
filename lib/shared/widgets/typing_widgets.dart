import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 打字输入框组件
class TypingInput extends StatefulWidget {
  final String targetWord;
  final void Function(String) onTextChanged;
  final void Function() onCorrect;
  final bool isEnabled;
  final TextStyle? textStyle;

  const TypingInput({
    super.key,
    required this.targetWord,
    required this.onTextChanged,
    required this.onCorrect,
    this.isEnabled = true,
    this.textStyle,
  });

  @override
  State<TypingInput> createState() => _TypingInputState();
}

class _TypingInputState extends State<TypingInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<bool> _charCorrect = [];

  @override
  void initState() {
    super.initState();
    _charCorrect = List.filled(widget.targetWord.length, false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _checkInput(String text) {
    // Call onTextChanged callback
    widget.onTextChanged(text);

    if (text.length <= widget.targetWord.length) {
      setState(() {
        for (int i = 0; i < text.length; i++) {
          _charCorrect[i] = text[i] == widget.targetWord[i];
        }
      });
    }

    if (text == widget.targetWord && widget.isEnabled) {
      widget.onCorrect();
      // Play success feedback
      SystemSound.play(SystemSoundType.click);
    } else if (text.length == widget.targetWord.length) {
      // Play error feedback
      SystemSound.play(SystemSoundType.alert);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Target word display
        Text(
          widget.targetWord,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: widget.isEnabled ? Colors.black : Colors.grey,
          ).merge(widget.textStyle),
        ),
        const SizedBox(height: 20),
        // Typing input
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.isEnabled,
          style: widget.textStyle,
          decoration: InputDecoration(
            hintText: 'Type the word above',
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: _checkInput,
          onSubmitted: widget.isEnabled ? (_) => _checkInput(_controller.text) : null,
        ),
        const SizedBox(height: 10),
        // Character correctness indicators
        if (_controller.text.isNotEmpty)
          Wrap(
            spacing: 4,
            children: List.generate(
              _controller.text.length.clamp(0, widget.targetWord.length).toInt(),
              (index) => Icon(
                _charCorrect[index] ? Icons.check_circle : Icons.cancel,
                size: 20,
                color: _charCorrect[index] ? Colors.green : Colors.red,
              ),
            ),
          ),
      ],
    );
  }
}

/// 统计显示组件
class TypingStats extends StatelessWidget {
  final int wpm; // Words per minute
  final double accuracy; // 0.0 to 1.0
  final int correctCount;
  final int totalCount;

  const TypingStats({
    super.key,
    required this.wpm,
    required this.accuracy,
    required this.correctCount,
    required this.totalCount,
  });

  double get accuracyPercentage => accuracy * 100;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStat('Speed', '$wpm WPM'),
                _buildStat('Accuracy', '${accuracyPercentage.toStringAsFixed(1)}%'),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: accuracy,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                accuracy > 0.8 ? Colors.green : accuracy > 0.5 ? Colors.orange : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$correctCount / $totalCount correct',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
