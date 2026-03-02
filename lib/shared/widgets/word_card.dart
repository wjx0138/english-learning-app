import 'package:flutter/material.dart';

/// 简单的单词卡片组件
class WordCard extends StatelessWidget {
  final String word;
  final String? phonetic;
  final String definition;
  final bool showBack;
  final VoidCallback? onTap;

  const WordCard({
    super.key,
    required this.word,
    this.phonetic,
    required this.definition,
    this.showBack = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: double.infinity,
          height: 300,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!showBack) ...[
                // Front of card
                Text(
                  word,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (phonetic != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    phonetic!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ] else ...[
                // Back of card
                Text(
                  definition,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
