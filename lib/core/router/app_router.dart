import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/app_user.dart';
import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/catalog/presentation/categories_screen.dart';
import '../../features/catalog/presentation/home_screen.dart';
import '../../features/catalog/presentation/product_details_screen.dart';
import '../../features/cart/presentation/cart_screen.dart';
import '../../features/checkout/presentation/checkout_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/orders/presentation/order_details_screen.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/admin/dashboard/presentation/admin_dashboard_screen.dart';
import '../../features/admin/banners/presentation/manage_banners_screen.dart';
import '../../features/admin/orders/presentation/manage_orders_screen.dart';
import '../../features/admin/products/presentation/manage_products_screen.dart';
import '../../features/admin/products/presentation/product_form_screen.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/favorites/presentation/favorites_screen.dart';
import 'admin_shell.dart';
import 'user_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// ⚠️ ملاحظة أمنية مهمة:
/// كل التوجيه هنا هو حماية على مستوى الواجهة (UX) فقط — يمنع الوميض
/// (flicker) ويخفي شاشات لا تخص المستخدم. **الحماية الفعلية والملزمة
/// تُفرض على الخادم** عبر Firestore Security Rules وCloud Functions التي
/// تتحقق من custom claims الخاصة بالدور. لا تعتمد أبداً على هذا الراوتر
/// وحده لحماية بيانات حسّاسة.
///
/// نموذج الوصول:
/// - عامة بالكامل (تعمل كضيف بدون تسجيل دخول): الرئيسية، التصنيفات،
///   تفاصيل المنتج، السلة (محلية على الجهاز).
/// - "طلباتي" و"حسابي" و"التنبيهات": يبقيان متاحين للضيف ملاحياً (لا حجب
///   على مستوى الراوتر)، لكن الشاشات نفسها تعرض دعوة لتسجيل الدخول بدل
///   المحتوى إن كان المستخدم ضيفاً — تجربة أنعم من إعادة توجيه فجائية.
/// - محمية فعلياً على مستوى الراوتر (لأنها إجراءات وليست مجرد عرض بيانات):
///   `/checkout` ومسارات `/admin/*`.
final _guestRequiresLoginPrefixes = ['/checkout', '/admin'];

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    refreshListenable: _GoRouterRefreshStream(ref),
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoading = authState.isLoading;
      final path = state.matchedLocation;
      final onAuthScreen = path == '/login' || path == '/register';

      if (isLoading) return null; // انتظر حتى تُحسم حالة المصادقة قبل التوجيه

      if (!isLoggedIn) {
        final needsLogin = _guestRequiresLoginPrefixes.any((p) => path.startsWith(p));
        if (needsLogin) {
          // نحفظ الوجهة الأصلية كي تعيد شاشة الدخول المستخدم إليها بعد
          // نجاح تسجيل الدخول مباشرة (مثال: السلة → checkout → login → checkout).
          return '/login?redirect=${Uri.encodeComponent(state.uri.toString())}';
        }
        return null; // تصفح كضيف: مسموح بكل ما عدا ذلك
      }

      // من هنا فصاعداً: المستخدم مسجّل دخوله بالفعل.
      final user = authState.value as AppUser;
      if (onAuthScreen) {
        return user.isAdminOrManager ? '/admin' : '/home';
      }
      final goingToAdmin = path.startsWith('/admin');
      // حماية واجهة فقط: تمنع مستخدماً عادياً من فتح شاشات الإدارة في
      // العميل (admin أو manager مسموح لهما). القرار الفعلي والملزم يُتخذ
      // في الخادم بغض النظر عن هذا الشرط.
      if (goingToAdmin && !user.isAdminOrManager) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),

      // ---------- فرع المستخدم العادي ----------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => UserShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/categories', builder: (context, state) => const CategoriesScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/orders', builder: (context, state) => const OrdersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),

      // مسارات تفتح فوق الشِل (بدون شريط تنقل سفلي)
      GoRoute(
        path: '/product/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ProductDetailsScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checkout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/orders/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => OrderDetailsScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/about',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
      GoRoute(
        path: '/favorites',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FavoritesScreen(),
      ),

      // ---------- فرع المدير ----------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AdminShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/products', builder: (context, state) => const ManageProductsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/orders', builder: (context, state) => const ManageOrdersScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/admin/profile', builder: (context, state) => const ProfileScreen()),
          ]),
        ],
      ),
      GoRoute(
        path: '/admin/products/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/admin/products/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ProductFormScreen(productId: state.pathParameters['id']),
      ),
      GoRoute(
        path: '/admin/banners',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ManageBannersScreen(),
      ),
    ],
  );
});

/// يجسّر Riverpod's AsyncValue stream مع Listenable الذي يحتاجه go_router
/// لإعادة تقييم redirect عند تغيّر حالة المصادقة (تسجيل دخول/خروج).
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Ref ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }
}
