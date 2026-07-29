import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/mock_auth_repository.dart';
import '../domain/app_user.dart';

/// غيّر هذا المزوّد إلى FirebaseAuthRepository() عند ربط Firebase الفعلي
/// (بعد تشغيل `flutterfire configure` وتفعيل Authentication في المشروع).
final authRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepository());

final authStateProvider = StreamProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// الدور الحالي — يُستخدم فقط لأغراض واجهة المستخدم (إخفاء/إظهار عناصر).
/// التحقق الأمني الفعلي يتم دوماً على الخادم (Firestore Rules / Cloud Functions).
final currentUserRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(authStateProvider).value?.role;
});
