import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/cart_providers.dart';
import '../../orders/presentation/orders_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _addressController = TextEditingController();
  bool _isPlacing = false;

  Future<void> _placeOrder() async {
    final items = ref.read(cartProvider);
    if (items.isEmpty) return;
    setState(() => _isPlacing = true);
    try {
      final total = ref.read(cartTotalProvider);
      await ref.read(ordersRepositoryProvider).placeOrder(items: items, total: total);
      ref.read(cartProvider.notifier).clear();
      if (mounted) {
        context.go('/orders');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء طلبك بنجاح ✓')));
      }
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final money = ref.watch(currencyFormatterProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.checkout)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.checkoutAddress, style: AppTextStyles.headlineSm(), textAlign: TextAlign.right),
                  const SizedBox(height: AppSpacing.stackMd),
                  AppTextField(
                    hint: 'الرياض، حي النخيل، شارع الأمير...',
                    controller: _addressController,
                    prefixIcon: Icons.location_on_outlined,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.checkoutPayment, style: AppTextStyles.headlineSm(), textAlign: TextAlign.right),
                  const SizedBox(height: AppSpacing.stackMd),
                  // طرق الدفع تُترك فارغة حالياً بناءً على طلبكم — سيتم دمج
                  // بوابة الدفع (مثل Moyasar / Tap / HyperPay) لاحقاً.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.stackLg),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.outlineVariant, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.credit_card_off_outlined, color: AppColors.outline, size: 28),
                        const SizedBox(height: AppSpacing.stackSm),
                        Text(t.noPaymentMethodsYet,
                            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(money.format(total),
                      style: AppTextStyles.headlineSm(color: AppColors.primary)),
                  Text(t.total, style: AppTextStyles.headlineSm()),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          PrimaryButton(label: t.placeOrder, onPressed: _placeOrder, isLoading: _isPlacing),
        ],
      ),
    );
  }
}
