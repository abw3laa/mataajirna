import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';

class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(i, initialLocation: i == navigationShell.currentIndex),
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.grid_view_rounded), label: t.adminDashboard),
          BottomNavigationBarItem(icon: const Icon(Icons.inventory_2_outlined), label: t.manageProducts),
          BottomNavigationBarItem(icon: const Icon(Icons.assignment_outlined), label: t.manageOrders),
          BottomNavigationBarItem(icon: const Icon(Icons.person_outline_rounded), label: t.account),
        ],
      ),
    );
  }
}
