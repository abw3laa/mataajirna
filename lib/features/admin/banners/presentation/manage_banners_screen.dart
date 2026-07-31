import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../banners/domain/promo_banner.dart';
import '../../../banners/presentation/banners_providers.dart';

class ManageBannersScreen extends ConsumerWidget {
  const ManageBannersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsync = ref.watch(allBannersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة البانرات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showBannerForm(context, ref, null),
          ),
        ],
      ),
      body: bannersAsync.when(
        data: (banners) {
          if (banners.isEmpty) {
            return EmptyView(
              title: 'لا توجد بانرات بعد',
              subtitle: 'أضف بانراً ليظهر في الصفحة الرئيسية للمستخدمين',
              icon: Icons.campaign_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            itemCount: banners.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.stackSm),
            itemBuilder: (context, i) {
              final b = banners[i];
              return Card(
                child: ListTile(
                  onTap: () => _showBannerForm(context, ref, b),
                  leading: Icon(
                    Icons.campaign_rounded,
                    color: b.isActive ? AppColors.primary : AppColors.outline,
                  ),
                  title: Text(b.title.replaceAll('\n', ' '), textAlign: TextAlign.right, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(b.isActive ? 'نشط' : 'غير نشط', textAlign: TextAlign.right),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    onPressed: () => ref.read(bannersRepositoryProvider).deleteBanner(b.id),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => AppErrorView(title: 'حدث خطأ ما', message: e.toString(), retryLabel: 'إعادة المحاولة', onRetry: () => ref.invalidate(allBannersProvider)),
      ),
    );
  }

  void _showBannerForm(BuildContext context, WidgetRef ref, PromoBanner? existing) {
    final titleController = TextEditingController(text: existing?.title);
    final badgeController = TextEditingController(text: existing?.badgeLabel ?? 'عرض خاص');
    final ctaController = TextEditingController(text: existing?.ctaLabel ?? 'تسوق الآن');
    bool isActive = existing?.isActive ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.marginMobile,
            right: AppSpacing.marginMobile,
            top: AppSpacing.marginMobile,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSpacing.marginMobile,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(existing == null ? 'إضافة بانر' : 'تعديل البانر',
                      style: AppTextStyles.headlineSm(), textAlign: TextAlign.center),
                  const SizedBox(height: AppSpacing.stackMd),
                  AppTextField(label: 'عنوان البانر', controller: titleController, maxLines: 2),
                  const SizedBox(height: AppSpacing.stackMd),
                  AppTextField(label: 'نص الشارة', controller: badgeController),
                  const SizedBox(height: AppSpacing.stackMd),
                  AppTextField(label: 'نص الزر', controller: ctaController),
                  const SizedBox(height: AppSpacing.stackMd),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('نشط'),
                      Switch(
                        value: isActive,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setSheetState(() => isActive = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.stackLg),
                  PrimaryButton(
                    label: 'حفظ',
                    onPressed: () async {
                      await ref.read(bannersRepositoryProvider).upsertBanner(
                            PromoBanner(
                              id: existing?.id ?? 'b-${DateTime.now().millisecondsSinceEpoch}',
                              title: titleController.text,
                              badgeLabel: badgeController.text,
                              ctaLabel: ctaController.text,
                              isActive: isActive,
                            ),
                          );
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
