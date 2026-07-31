import 'package:flutter_riverpod/flutter_riverpod.dart';

/// قائمة معرّفات المنتجات المفضّلة — محلية على الجهاز حالياً.
/// عند ربط Firebase الفعلي، يمكن مزامنتها مع `users/{uid}/favorites`
/// بنفس نمط بقية المزوّدات (mock/Firestore حسب kUseFirebase).
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super(<String>{});

  void toggle(String productId) {
    final updated = {...state};
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    state = updated;
  }

  bool isFavorite(String productId) => state.contains(productId);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(),
);
