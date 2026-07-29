import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock_orders_repository.dart';
import '../data/orders_repository.dart';
import '../domain/order.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) => MockOrdersRepository());

final myOrdersProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(ordersRepositoryProvider).watchMyOrders();
});

final allOrdersProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(ordersRepositoryProvider).watchAllOrders();
});

final ordersFilterProvider = StateProvider<OrderStatus?>((ref) => null);
