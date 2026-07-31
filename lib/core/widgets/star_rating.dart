import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// عرض تقييم بالنجوم. لا يعتمد على اللون وحده للإفهام (إمكانية وصول) —
/// يُظهر دائماً القيمة الرقمية بجانب النجوم.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 16, this.showValue = true});

  final double rating; // 0-5
  final double size;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showValue) ...[
          Text(rating.toStringAsFixed(1), style: AppTextStyles.labelMd()),
          const SizedBox(width: 4),
        ],
        Row(
          children: List.generate(5, (i) {
            final filled = i < rating.round();
            return Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              size: size,
              color: AppColors.accent,
            );
          }),
        ),
      ],
    );
  }
}

/// نجوم قابلة للاختيار (لإدخال تقييم جديد).
class StarRatingInput extends StatelessWidget {
  const StarRatingInput({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final starValue = i + 1;
        return IconButton(
          onPressed: () => onChanged(starValue),
          icon: Icon(
            starValue <= value ? Icons.star_rounded : Icons.star_border_rounded,
            color: AppColors.accent,
            size: 32,
          ),
        );
      }),
    );
  }
}
