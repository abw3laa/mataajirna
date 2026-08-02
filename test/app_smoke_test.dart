import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mataajirna/app.dart';
import 'package:mataajirna/features/auth/data/mock_auth_repository.dart';
import 'package:mataajirna/features/auth/presentation/auth_providers.dart';
import 'package:mataajirna/features/catalog/data/mock_catalog_repository.dart';
import 'package:mataajirna/features/catalog/presentation/catalog_providers.dart';
import 'package:mataajirna/features/orders/data/mock_orders_repository.dart';
import 'package:mataajirna/features/orders/presentation/orders_providers.dart';

/// نجبر الاختبارات دوماً على استخدام مستودعات Mock — بصرف النظر عن قيمة
/// kUseFirebase الفعلية في التطبيق — لتجنّب الحاجة لتهيئة Firebase حقيقية
/// (وMissingPluginException) داخل بيئة الاختبار.
List<Override> get _mockOverrides => [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
      catalogRepositoryProvider.overrideWithValue(MockCatalogRepository()),
      ordersRepositoryProvider.overrideWithValue(MockOrdersRepository()),
    ];

void main() {
  testWidgets('يقلع التطبيق ويعرض الرئيسية مباشرة (تصفح كضيف)', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: _mockOverrides, child: const MatajirnaApp()));
    await tester.pumpAndSettle();

    // منذ دعم تصفح الضيف، يفتح التطبيق على الرئيسية مباشرة بدون تسجيل
    // دخول إجباري — نتحقق من ظهور اسم التطبيق في شريط العنوان.
    expect(find.text('متجرنا'), findsWidgets);
    // شريط البحث في الرئيسية يؤكد أننا فعلاً في شاشة التصفح وليست شاشة فارغة.
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('الانتقال لشاشة الدخول يعرض عنوان "مرحباً بعودتك"', (tester) async {
    await tester.pumpWidget(ProviderScope(overrides: _mockOverrides, child: const MatajirnaApp()));
    await tester.pumpAndSettle();

    // نتنقّل يدوياً لشاشة الدخول (بدل الاعتماد على كونها الشاشة الافتراضية).
    final BuildContext context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).push('/login');
    await tester.pumpAndSettle();

    expect(find.text('مرحباً بعودتك'), findsOneWidget);
  });
}
