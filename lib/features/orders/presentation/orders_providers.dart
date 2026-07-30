import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/backend_config.dart';
import '../data/firestore_orders_repository.dart';
import '../data/mock_orders_repository.dart';
import '../data/orders_repository.dart';
import '../domain/order.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return kUseFirebase ? FirestoreOrdersRepository() : MockOrdersRepository();
});

final myOrdersProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(ordersRepositoryProvider).watchMyOrders();
});

final allOrdersProvider = StreamProvider<List<Order>>((ref) {
  return ref.watch(ordersRepositoryProvider).watchAllOrders();
});

final ordersFilterProvider = StateProvider<OrderStatus?>((ref) => null);
