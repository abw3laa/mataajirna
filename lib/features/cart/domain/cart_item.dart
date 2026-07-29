import 'package:equatable/equatable.dart';
import '../../catalog/domain/product.dart';

class CartItem extends Equatable {
  const CartItem({required this.product, required this.quantity, this.selectedColor});

  final Product product;
  final int quantity;
  final String? selectedColor;

  double get unitPrice => product.discountPrice ?? product.price;
  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity, selectedColor: selectedColor);

  @override
  List<Object?> get props => [product.id, quantity, selectedColor];
}
