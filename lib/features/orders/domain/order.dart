import 'package:equatable/equatable.dart';
import '../../cart/domain/cart_item.dart';

enum OrderStatus { pending, processing, shipped, completed, cancelled }

extension OrderStatusX on OrderStatus {
  static OrderStatus fromString(String value) =>
      OrderStatus.values.firstWhere((s) => s.name == value, orElse: () => OrderStatus.pending);
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.customerName,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.address,
  });

  final String id;
  final String customerName;
  final String userId;
  final List<CartItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String? address;

  Order copyWith({OrderStatus? status}) => Order(
        id: id,
        customerName: customerName,
        userId: userId,
        items: items,
        total: total,
        status: status ?? this.status,
        createdAt: createdAt,
        address: address,
      );

  @override
  List<Object?> get props => [id, status, total];
}
