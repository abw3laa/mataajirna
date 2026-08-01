import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mataajirna/app.dart';

void main() {
  testWidgets('يقلع التطبيق ويعرض الرئيسية مباشرة (تصفح كضيف)', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MatajirnaApp()));
    await tester.pumpAndSettle();

    // منذ دعم تصفح الضيف، يفتح التطبيق على الرئيسية مباشرة بدون تسجيل
    // دخول إجباري — نتحقق من ظهور اسم التطبيق في شريط العنوان.
    expect(find.text('متجرنا'), findsWidgets);
    // شريط البحث في الرئيسية يؤكد أننا فعلاً في شاشة التصفح وليست شاشة فارغة.
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('الانتقال لشاشة الدخول يعرض عنوان "مرحباً بعودتك"', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MatajirnaApp()));
    await tester.pumpAndSettle();

    // نتنقّل يدوياً لشاشة الدخول (بدل الاعتماد على كونها الشاشة الافتراضية).
    final BuildContext context = tester.element(find.byType(Scaffold).first);
    GoRouter.of(context).push('/login');
    await tester.pumpAndSettle();

    expect(find.text('مرحباً بعودتك'), findsOneWidget);
  });
}
