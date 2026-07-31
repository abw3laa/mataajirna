import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// شبكة بطاقات وهمية بتأثير Shimmer، تحاكي شكل [ProductCard] أثناء التحميل.
/// تُعطي شعوراً أكثر احترافية من دائرة تحميل مركزية فارغة.
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({super.key, this.itemCount = 6, this.shrinkWrap = true});

  final int itemCount;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceContainer,
      highlightColor: AppColors.surfaceContainerLowest,
      child: GridView.builder(
        shrinkWrap: shrinkWrap,
        physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
        padding: shrinkWrap ? EdgeInsets.zero : const EdgeInsets.all(AppSpacing.marginMobile),
        itemCount: itemCount,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.stackMd,
          crossAxisSpacing: AppSpacing.stackMd,
          childAspectRatio: 0.62,
        ),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.stackMd),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 10, width: 60, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 14, width: double.infinity, color: Colors.white),
                      const SizedBox(height: 6),
                      Container(height: 14, width: 100, color: Colors.white),
                      const SizedBox(height: 12),
                      Container(height: 16, width: 70, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
