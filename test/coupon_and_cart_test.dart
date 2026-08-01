import 'package:flutter_test/flutter_test.dart';
import 'package:mataajirna/features/checkout/domain/coupon.dart';
import 'package:mataajirna/features/catalog/domain/product.dart';
import 'package:mataajirna/features/cart/domain/cart_item.dart';

Product _product({double price = 100, double? discountPrice}) => Product(
      id: 'p1',
      name: 'منتج تجريبي',
      description: '',
      price: price,
      discountPrice: discountPrice,
      categoryId: 'c1',
      categoryName: 'تصنيف',
      imageUrl: '',
      inStock: true,
    );

void main() {
  group('CouponValidator', () {
    test('يقبل كوداً صحيحاً بأي حالة أحرف', () {
      expect(CouponValidator.validate('save10')?.discountPercent, 10);
      expect(CouponValidator.validate('SAVE10')?.discountPercent, 10);
      expect(CouponValidator.validate('  save20  ')?.discountPercent, 20);
    });

    test('يرفض كوداً غير موجود', () {
      expect(CouponValidator.validate('INVALIDCODE'), isNull);
    });

    test('يرفض كوداً فارغاً', () {
      expect(CouponValidator.validate(''), isNull);
    });
  });

  group('CartItem', () {
    test('يستخدم سعر الخصم إن وُجد لحساب الإجمالي', () {
      final item = CartItem(product: _product(price: 100, discountPrice: 80), quantity: 2);
      expect(item.unitPrice, 80);
      expect(item.lineTotal, 160);
    });

    test('يستخدم السعر الأساسي عند غياب الخصم', () {
      final item = CartItem(product: _product(price: 100), quantity: 3);
      expect(item.unitPrice, 100);
      expect(item.lineTotal, 300);
    });
  });
}
