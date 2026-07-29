import 'dart:async';
import '../../catalog/domain/product.dart';
import '../../cart/domain/cart_item.dart';
import '../domain/order.dart';
import 'orders_repository.dart';

class MockOrdersRepository implements OrdersRepository {
  final _controller = StreamController<List<Order>>.broadcast();

  late final List<Order> _orders = [
    Order(
      id: 'ORD-88392',
      customerName: 'أحمد عبدالله',
      userId: 'user-uid',
      items: const [
        CartItem(
          product: Product(
            id: 'p11',
            name: 'محفظة جلدية فاخرة',
            description: '',
            price: 120,
            categoryId: 'fashion',
            categoryName: 'إكسسوارات',
            imageUrl: 'https://picsum.photos/seed/wallet1/300',
            inStock: true,
          ),
          quantity: 1,
        ),
      ],
      total: 1450,
      status: OrderStatus.shipped,
      createdAt: DateTime(2023, 10, 24),
    ),
    Order(
      id: 'ORD-88405',
      customerName: 'أحمد عبدالله',
      userId: 'user-uid',
      items: const [
        CartItem(
          product: Product(
            id: 'p2',
            name: 'سماعات رأس لاسلكية',
            description: '',
            price: 890,
            categoryId: 'electronics',
            categoryName: 'إلكترونيات',
            imageUrl: 'https://picsum.photos/seed/headphones1/300',
            inStock: true,
          ),
          quantity: 1,
        ),
      ],
      total: 890,
      status: OrderStatus.pending,
      createdAt: DateTime(2023, 10, 25),
    ),
    Order(
      id: 'ORD-87102',
      customerName: 'سارة خالد',
      userId: 'user-2',
      items: const [
        CartItem(
          product: Product(
            id: 'p3',
            name: 'مجموعة القهوة المختصة',
            description: '',
            price: 160,
            categoryId: 'home',
            categoryName: 'المنزل',
            imageUrl: 'https://picsum.photos/seed/coffee1/300',
            inStock: true,
          ),
          quantity: 2,
        ),
      ],
      total: 320,
      status: OrderStatus.completed,
      createdAt: DateTime(2023, 10, 12),
    ),
  ];

  void _emit() => _controller.add(List.unmodifiable(_orders));

  @override
  Stream<List<Order>> watchMyOrders() async* {
    yield _orders.where((o) => o.userId == 'user-uid').toList();
    yield* _controller.stream
        .map((list) => list.where((o) => o.userId == 'user-uid').toList());
  }

  @override
  Stream<List<Order>> watchAllOrders() async* {
    yield _orders;
    yield* _controller.stream;
  }

  @override
  Future<Order> placeOrder(
      {required List<CartItem> items, required double total}) async {
    final order = Order(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch % 100000}',
      customerName: 'أحمد عبدالله',
      userId: 'user-uid',
      items: items,
      total: total,
      status: OrderStatus.pending,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, order);
    _emit();
    return order;
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      _orders[idx] = _orders[idx].copyWith(status: status);
      _emit();
    }
  }
}
