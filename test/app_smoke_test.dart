import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mataajirna/app.dart';

void main() {
  testWidgets('يقلع التطبيق ويعرض شاشة تسجيل الدخول', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MatajirnaApp()));
    await tester.pumpAndSettle();

    // شاشة الدخول تعرض عنوان "مرحباً بعودتك"
    expect(find.text('مرحباً بعودتك'), findsOneWidget);
  });
}
