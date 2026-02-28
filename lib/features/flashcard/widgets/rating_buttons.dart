import 'package:flutter/material.dart';
import '../../../core/utils/srs_algorithm.dart';

/// Swipe-to-Rate Widget for Flashcards
class CardRatingButtons extends StatelessWidget {
  final bool showAnswer;
  final Function(int rating) onRate;
  final bool isVertical;

  const CardRatingButtons({
    super.key,
    required this.showAnswer,
    required this.onRate,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!showAnswer) {
      return const SizedBox.shrink();
    }

    if (isVertical) {
      return _buildVerticalButtons(context);
    }

    return _buildHorizontalButtons(context);
  }

  Widget _buildHorizontalButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildRatingButton(
            context,
            label: '再来',
            icon: Icons.refresh,
            color: Colors.red,
            rating: FSRSAlgorithm.ratingAgain,
          ),
          _buildRatingButton(
            context,
            label: '困难',
            icon: Icons.trending_up,
            color: Colors.orange,
            rating: FSRSAlgorithm.ratingHard,
          ),
          _buildRatingButton(
            context,
            label: '良好',
            icon: Icons.check_circle,
            color: Colors.green,
            rating: FSRSAlgorithm.ratingGood,
          ),
          _buildRatingButton(
            context,
            label: '简单',
            icon: Icons.star,
            color: Colors.blue,
            rating: FSRSAlgorithm.ratingEasy,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVerticalRatingButton(
            context,
            label: '简单',
            icon: Icons.star,
            color: Colors.blue,
            rating: FSRSAlgorithm.ratingEasy,
          ),
          const SizedBox(height: 12),
          _buildVerticalRatingButton(
            context,
            label: '良好',
            icon: Icons.check_circle,
            color: Colors.green,
            rating: FSRSAlgorithm.ratingGood,
          ),
          const SizedBox(height: 12),
          _buildVerticalRatingButton(
            context,
            label: '困难',
            icon: Icons.trending_up,
            color: Colors.orange,
            rating: FSRSAlgorithm.ratingHard,
          ),
          const SizedBox(height: 12),
          _buildVerticalRatingButton(
            context,
            label: '再来',
            icon: Icons.refresh,
            color: Colors.red,
            rating: FSRSAlgorithm.ratingAgain,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingButton(
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
          onPressed: () => onRate(rating),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalRatingButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required int rating,
  }) {
    return SizedBox(
      width: 80,
      child: ElevatedButton(
        onPressed: () => onRate(rating),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Swipeable Card Wrapper
class SwipeableCardWrapper extends StatelessWidget {
  final Widget child;
  final Function(int rating) onSwipe;
  final bool enabled;

  const SwipeableCardWrapper({
    super.key,
    required this.child,
    required this.onSwipe,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }

    // For simplicity, using buttons instead of swipe gestures
    // Swipe gestures can be added later with flutter_slidable package
    return child;
  }
}

/// Compact Rating Button for Small Screens
class CompactRatingButtons extends StatelessWidget {
  final bool showAnswer;
  final Function(int rating) onRate;

  const CompactRatingButtons({
    super.key,
    required this.showAnswer,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    if (!showAnswer) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
        children: [
          _buildCompactButton(
            context,
            label: '再来',
            color: Colors.red,
            rating: FSRSAlgorithm.ratingAgain,
          ),
          _buildCompactButton(
            context,
            label: '困难',
            color: Colors.orange,
            rating: FSRSAlgorithm.ratingHard,
          ),
          _buildCompactButton(
            context,
            label: '良好',
            color: Colors.green,
            rating: FSRSAlgorithm.ratingGood,
          ),
          _buildCompactButton(
            context,
            label: '简单',
            color: Colors.blue,
            rating: FSRSAlgorithm.ratingEasy,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactButton(
    BuildContext context, {
    required String label,
    required Color color,
    required int rating,
  }) {
    return ElevatedButton(
      onPressed: () => onRate(rating),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
