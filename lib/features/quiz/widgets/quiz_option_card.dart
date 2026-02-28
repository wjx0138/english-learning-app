import 'package:flutter/material.dart';
import '../../../data/models/quiz.dart';

/// Quiz Option Card Widget
class QuizOptionCard extends StatelessWidget {
  final QuizOption option;
  final int index;
  final bool isSelected;
  final bool isRevealed;
  final bool showExplanation;
  final VoidCallback onTap;

  const QuizOptionCard({
    super.key,
    required this.option,
    required this.index,
    this.isSelected = false,
    this.isRevealed = false,
    this.showExplanation = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCorrect = option.isCorrect;
    final showResult = isRevealed;

    // Determine colors based on state
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
        textColor = Colors.red.shade900;
        icon = Icons.cancel;
      } else {
        backgroundColor = Colors.grey.shade50;
        borderColor = Colors.grey.shade300;
        textColor = Colors.grey.shade700;
      }
    } else if (isSelected) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      borderColor = Theme.of(context).colorScheme.primary;
      textColor = Theme.of(context).colorScheme.onPrimaryContainer;
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey.shade300;
      textColor = Colors.grey.shade800;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: showResult ? null : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: borderColor,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Option letter
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      String.fromCharCode(65 + index), // A, B, C, D
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Option text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      if (showExplanation && showResult && isCorrect)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '✓ 正确答案',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Icon
                if (showResult && icon != null)
                  Icon(
                    icon,
                    color: borderColor,
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Quiz Question Card Widget
class QuizQuestionCard extends StatelessWidget {
  final QuizQuestion question;
  final int currentIndex;
  final int totalQuestions;
  final bool isRevealed;

  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.currentIndex,
    required this.totalQuestions,
    this.isRevealed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    '题目 ${currentIndex + 1}/$totalQuestions',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
                if (question.type != QuizQuestionType.reverseDefinition)
                  Chip(
                    label: Text(_getTypeLabel(question.type)),
                    backgroundColor: Colors.blue.shade100,
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Question text
            Text(
              question.question,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Explanation (if revealed)
            if (isRevealed && question.explanation != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Text(
                          '解析',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation!,
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTypeLabel(QuizQuestionType type) {
    switch (type) {
      case QuizQuestionType.definition:
        return '选择题';
      case QuizQuestionType.reverseDefinition:
        return '逆选题';
      case QuizQuestionType.synonym:
        return '同义词';
      case QuizQuestionType.antonym:
        return '反义词';
      case QuizQuestionType.fillBlank:
        return '填空题';
    }
  }
}
