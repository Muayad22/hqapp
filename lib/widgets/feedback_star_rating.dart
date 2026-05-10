import 'package:flutter/material.dart';

/// Tappable 1–5 star row for feedback forms.
class FeedbackStarRatingPicker extends StatelessWidget {
  const FeedbackStarRatingPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        final filled = starIndex <= value;
        return IconButton(
          onPressed: () => onChanged(starIndex),
          icon: Icon(
            filled ? Icons.star : Icons.star_border,
            color: filled ? const Color(0xFFDAA520) : Colors.grey,
            size: 40,
          ),
          splashRadius: 28,
        );
      }),
    );
  }
}

/// Read-only compact stars for lists (admin feedback, etc.).
class FeedbackStarRatingDisplay extends StatelessWidget {
  const FeedbackStarRatingDisplay({super.key, required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < rating ? Icons.star : Icons.star_border,
          size: 18,
          color: const Color(0xFFDAA520),
        ),
      ),
    );
  }
}
