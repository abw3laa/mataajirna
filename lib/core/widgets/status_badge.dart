import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum BadgeTone { primary, error, success, warning, info, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, this.tone = BadgeTone.primary, this.icon});

  final String label;
  final BadgeTone tone;
  final IconData? icon;

  (Color bg, Color fg) get _colors => switch (tone) {
        BadgeTone.primary => (AppColors.primary, Colors.white),
        BadgeTone.error => (AppColors.errorContainer, AppColors.onErrorContainer),
        BadgeTone.success => (const Color(0xFFD7F5E9), AppColors.success),
        BadgeTone.warning => (const Color(0xFFF6E3CE), AppColors.warning),
        BadgeTone.info => (AppColors.secondaryContainer, AppColors.onSecondaryContainer),
        BadgeTone.neutral => (AppColors.surfaceContainerHigh, AppColors.onSurfaceVariant),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 12, color: fg), const SizedBox(width: 4)],
          Text(label, style: AppTextStyles.labelSm(color: fg)),
        ],
      ),
    );
  }
}
