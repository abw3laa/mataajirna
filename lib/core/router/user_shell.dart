import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/cart/presentation/cart_providers.dart';
import '../../l10n/app_localizations.dart';

class UserShell extends ConsumerWidget {
  const UserShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final cartCount = ref.watch(cartCountProvider);

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home_outlined), activeIcon: const Icon(Icons.home_rounded), label: t.home),
          BottomNavigationBarItem(icon: const Icon(Icons.search_rounded), label: t.search),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: t.cart,
          ),
          BottomNavigationBarItem(icon: const Icon(Icons.local_shipping_outlined), label: t.orders),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline_rounded), label: t.account),
        ],
      ),
    );
  }
}
