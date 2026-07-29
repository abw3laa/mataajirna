import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalog/domain/product.dart';
import '../domain/cart_item.dart';

/// حالة السلة محلية على الجهاز (Riverpod) في هذا العرض التوضيحي.
/// في الإنتاج: يُزامَن مع مستند `carts/{uid}` في Firestore عبر مستودع
/// مخصص، بحيث تُقرأ/تُكتب فقط بيانات صاحب الحساب (تُفرض هذه القاعدة عبر
/// Firestore Security Rules: `request.auth.uid == uid`).
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super(const []);

  void add(Product product, {String? color}) {
    final idx = state.indexWhere((i) => i.product.id == product.id && i.selectedColor == color);
    if (idx == -1) {
      state = [...state, CartItem(product: product, quantity: 1, selectedColor: color)];
    } else {
      final updated = [...state];
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + 1);
      state = updated;
    }
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId) item.copyWith(quantity: quantity) else item,
    ];
  }

  void remove(String productId) {
    state = state.where((i) => i.product.id != productId).toList();
  }

  void clear() => state = const [];
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) => CartNotifier());

final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).fold<int>(0, (sum, item) => sum + item.quantity);
});

const kTaxRate = 0.15; // 15% ضريبة قيمة مضافة — قابلة للتهيئة لاحقاً من الخادم

final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).fold<double>(0, (sum, item) => sum + item.lineTotal);
});
final cartTaxProvider = Provider<double>((ref) => ref.watch(cartSubtotalProvider) * kTaxRate);
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartSubtotalProvider) + ref.watch(cartTaxProvider);
});
