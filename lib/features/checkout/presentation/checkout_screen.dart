import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/currency/currency_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../cart/presentation/cart_providers.dart';
import '../../notifications/domain/app_notification.dart';
import '../../notifications/presentation/notifications_providers.dart';
import '../../orders/presentation/orders_providers.dart';
import '../domain/coupon.dart';
import 'checkout_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _couponController = TextEditingController();
  bool _isPlacing = false;
  String? _couponError;

  void _applyCoupon() {
    final coupon = CouponValidator.validate(_couponController.text);
    setState(() {
      if (coupon == null) {
        _couponError = 'كود الخصم غير صالح';
      } else {
        _couponError = null;
        ref.read(appliedCouponProvider.notifier).state = coupon;
      }
    });
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;
    final items = ref.read(cartProvider);
    if (items.isEmpty) return;
    setState(() => _isPlacing = true);
    try {
      final coupon = ref.read(appliedCouponProvider);
      final order = await ref.read(ordersRepositoryProvider).placeOrder(
            items: items,
            couponCode: coupon?.code,
            address: Validators.sanitize(_addressController.text),
          );
      ref.read(cartProvider.notifier).clear();
      ref.read(appliedCouponProvider.notifier).state = null;
      ref.read(notificationsProvider.notifier).addNotification(
            AppNotification(
              id: 'order-${order.id}',
              title: 'تم استلام طلبك',
              body: 'طلبك رقم #${order.id} قيد المعالجة الآن.',
              type: NotificationType.orderUpdate,
              timeAgo: 'الآن',
              actionLabel: 'تتبع الطلب',
            ),
          );
      if (mounted) {
        context.go('/orders');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء طلبك بنجاح ✓')));
      }
    } catch (e) {
      // لا نعرض رسالة الاستثناء الخام (قد تحتوي تفاصيل تقنية أو داخلية) —
      // AppException.friendlyMessage يترجمها لرسالة مفهومة للمستخدم.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppException.friendlyMessage(e))),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final money = ref.watch(currencyFormatterProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final discount = ref.watch(couponDiscountProvider);
    final total = ref.watch(checkoutTotalProvider);
    final coupon = ref.watch(appliedCouponProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.checkout)),
      body: Form(
        key: _formKey,
        child: ListView(
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
                    validator: Validators.address,
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
                  Text('كود الخصم', style: AppTextStyles.headlineSm(), textAlign: TextAlign.right),
                  const SizedBox(height: AppSpacing.stackMd),
                  if (coupon != null)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.stackMd),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              ref.read(appliedCouponProvider.notifier).state = null;
                              _couponController.clear();
                            },
                            child: const Icon(Icons.close_rounded, size: 18, color: AppColors.onPrimaryContainer),
                          ),
                          const Spacer(),
                          Text(
                            'تم تطبيق كود ${coupon.code} (خصم ${coupon.discountPercent.toStringAsFixed(0)}%)',
                            style: AppTextStyles.bodyMd(color: AppColors.onPrimaryContainer),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    )
                  else
                    Row(
                      children: [
                        ElevatedButton(onPressed: _applyCoupon, child: const Text('تطبيق')),
                        const SizedBox(width: AppSpacing.stackSm),
                        Expanded(
                          child: AppTextField(hint: 'مثال: SAVE10', controller: _couponController),
                        ),
                      ],
                    ),
                  if (_couponError != null) ...[
                    const SizedBox(height: 8),
                    Text(_couponError!, style: AppTextStyles.labelMd(color: AppColors.error)),
                  ],
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _summaryRow(t.subtotal, money.format(subtotal)),
                  if (discount > 0) ...[
                    const SizedBox(height: 8),
                    _summaryRow('الخصم', '- ${money.format(discount)}', color: AppColors.primary),
                  ],
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(money.format(total), style: AppTextStyles.headlineSm(color: AppColors.primary)),
                      Text(t.total, style: AppTextStyles.headlineSm()),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.stackLg),
          PrimaryButton(label: t.placeOrder, onPressed: _placeOrder, isLoading: _isPlacing),
        ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(value, style: AppTextStyles.bodyMd(color: color)),
        Text(label, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}
